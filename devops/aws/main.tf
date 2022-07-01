################################################################################
################################################################################
################################################################################
# GENERAL CONFIGURATION
################################################################################
################################################################################
################################################################################
provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}

################################################################################
################################################################################
################################################################################
# VPC CONFIGURATION
################################################################################
################################################################################
################################################################################
module "networking" {
  source               = "./common/modules/network"
  create_vpc           = var.create_vpc
  create_igw           = var.create_igw
  single_nat_gateway   = var.single_nat_gateway
  enable_nat_gateway   = var.enable_nat_gateway
  region               = var.aws_region
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

################################################################################
################################################################################
################################################################################
# IAM CONFIGURATION
################################################################################
################################################################################
################################################################################

################################################################################
# ECS Tasks Execution IAM
################################################################################
# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# VPC Flow Logs IAM
################################################################################
resource "aws_iam_role" "vpc_flow_cloudwatch_logs_role" {
  name               = "collector-vpc-flow-cloudwatch-logs-role"
  assume_role_policy = file("./common/templates/policies/vpc_flow_cloudwatch_logs_role.json.tpl")
}

resource "aws_iam_role_policy" "vpc_flow_cloudwatch_logs_policy" {
  name   = "collector-vpc-flow-cloudwatch-logs-policy"
  role   = aws_iam_role.vpc_flow_cloudwatch_logs_role.id
  policy = file("./common/templates/policies/vpc_flow_cloudwatch_logs_policy.json.tpl")
}

# VPC Flows
################################################################################
# Provides a VPC/Subnet/ENI Flow Log to capture IP traffic for a specific network interface, 
# subnet, or VPC. Logs are sent to a CloudWatch Log Group or a S3 Bucket.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_cloudwatch_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = module.networking.vpc_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "collector-vpc-flow-logs"
  retention_in_days = 30
}

################################################################################
################################################################################
################################################################################
# SG CONFIGURATION
################################################################################
################################################################################
################################################################################
module "alb_sg" {
  source                   = "./common/modules/security"
  create_vpc               = var.create_vpc
  create_sg                = true
  sg_name                  = "load-balancer-security-group"
  description              = "controls access to the ALB"
  rule_ingress_description = "controls access to the ALB"
  rule_egress_description  = "allow all outbound"
  vpc_id                   = module.networking.vpc_id
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_from_port        = 80
  ingress_to_port          = 80
  ingress_protocol         = "tcp"
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_from_port         = 0
  egress_to_port           = 0
  egress_protocol          = "-1"
}

module "ecs_tasks_sg" {
  source                           = "./common/modules/security"
  create_vpc                       = var.create_vpc
  create_sg                        = true
  sg_name                          = "ecs-tasks-security-group"
  description                      = "controls access to the ECS tasks"
  rule_ingress_description         = "allow inbound access from the ALB only"
  rule_egress_description          = "allow all outbound"
  vpc_id                           = module.networking.vpc_id
  ingress_cidr_blocks              = null
  ingress_from_port                = 0
  ingress_to_port                  = 0
  ingress_protocol                 = "-1"
  ingress_source_security_group_id = module.alb_sg.security_group_id
  egress_cidr_blocks               = ["0.0.0.0/0"]
  egress_from_port                 = 0
  egress_to_port                   = 0
  egress_protocol                  = "-1"
}

module "private_database_sg" {
  source                   = "./common/modules/security"
  create_vpc               = var.create_vpc
  create_sg                = true
  sg_name                  = "private-database-security-group"
  description              = "Controls access to the private database (not internet facing)"
  rule_ingress_description = "allow inbound access only from resources in VPC"
  rule_egress_description  = "allow all outbound"
  vpc_id                   = module.networking.vpc_id
  ingress_cidr_blocks      = [var.cidr_block]
  ingress_from_port        = 0
  ingress_to_port          = 0
  ingress_protocol         = "-1"
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_from_port         = 0
  egress_to_port           = 0
  egress_protocol          = "-1"
}

module "private_vpc_sg" {
  source                   = "./common/modules/security"
  create_vpc               = var.create_vpc
  create_sg                = true
  sg_name                  = "private-lambda-security-group"
  description              = "Controls access to the private lambdas (not internet facing)"
  rule_ingress_description = "allow inbound access only from resources in VPC"
  rule_egress_description  = "allow all outbound"
  vpc_id                   = module.networking.vpc_id
  ingress_cidr_blocks      = [var.cidr_block]
  ingress_from_port        = 0
  ingress_to_port          = 0
  ingress_protocol         = "-1"
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_from_port         = 0
  egress_to_port           = 0
  egress_protocol          = "-1"
}

################################################################################
################################################################################
################################################################################
# LOAD BALANCER CONFIGURATION
################################################################################
################################################################################
################################################################################
module "public_alb" {
  source             = "./common/modules/alb"
  create_alb         = var.create_alb
  load_balancer_type = "application"
  alb_name           = "main-ecs-lb"
  internal           = false
  vpc_id             = module.networking.vpc_id
  security_groups    = [module.alb_sg.security_group_id]
  subnet_ids         = module.networking.public_subnet_ids
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Resource not found"
        status_code  = "404"
      }
    }
  ]
}

################################################################################
################################################################################
################################################################################
# ECS CLUSTER CONFIGURATION
################################################################################
################################################################################
################################################################################
module "ecs_cluster" {
  source                   = "./common/modules/ecs_cluster"
  project                  = var.project
  create_capacity_provider = false
}

resource "aws_service_discovery_private_dns_namespace" "segment" {
  name        = "discovery.com"
  description = "Service discovery for backends"
  vpc         = module.networking.vpc_id
}


################################################################################
################################################################################
################################################################################
# DATABASES CONFIGURATION
################################################################################
################################################################################
################################################################################
# Databases Secrets
# https://www.sufle.io/blog/keeping-secrets-as-secret-on-amazon-ecs-using-terraform
resource "aws_secretsmanager_secret" "collector_database_password_secret" {
  name = "collector_database_master_password"
}

resource "aws_secretsmanager_secret_version" "collector_database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.collector_database_password_secret.id
  secret_string = var.collector_database_password
}

resource "aws_secretsmanager_secret" "collector_database_username_secret" {
  name = "collector_database_master_username"
}

resource "aws_secretsmanager_secret_version" "collector_database_username_secret_version" {
  secret_id     = aws_secretsmanager_secret.collector_database_username_secret.id
  secret_string = var.collector_database_username
}

resource "aws_iam_role_policy" "collector_password_policy_secretsmanager" {
  name = "collector-password-policy-secretsmanager"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_secretsmanager_secret.collector_database_username_secret.arn}",
          "${aws_secretsmanager_secret.collector_database_password_secret.arn}"
        ]
      }
    ]
  }
  EOF
}

# collector Database
module "collector_database" {
  source               = "./common/modules/database"
  database_identifier  = var.collector_database_identifier
  database_username    = var.collector_database_username
  database_password    = var.collector_database_password
  subnet_ids           = module.networking.private_subnet_ids
  security_group_ids   = [module.private_database_sg.security_group_id]
  monitoring_role_name = var.collector_monitoring_role_name
}


################################################################################
################################################################################
################################################################################
# ECS FARGATE CONFIGURATION
################################################################################
################################################################################
################################################################################
# collector API ECS Service
module "ecs_collector_api_fargate" {
  source                                  = "./common/modules/ecs"
  aws_region                              = var.aws_region
  vpc_id                                  = module.networking.vpc_id
  cluster_id                              = module.ecs_cluster.cluster_id
  cluster_name                            = module.ecs_cluster.cluster_name
  has_discovery                           = true
  dns_namespace_id                        = aws_service_discovery_private_dns_namespace.segment.id
  service_security_groups_ids             = [module.ecs_tasks_sg.security_group_id]
  subnet_ids                              = module.networking.private_subnet_ids
  assign_public_ip                        = false
  iam_role_ecs_task_execution_role        = aws_iam_role.ecs_task_execution_role
  iam_role_policy_ecs_task_execution_role = aws_iam_role_policy_attachment.ecs_task_execution_role
  logs_retention_in_days                  = 30
  fargate_cpu                             = var.fargate_cpu
  fargate_memory                          = var.fargate_memory
  health_check_grace_period_seconds       = var.health_check_grace_period_seconds
  service_name                            = var.collector_api_name
  service_image                           = var.collector_api_image
  service_aws_logs_group                  = var.collector_api_aws_logs_group
  service_port                            = var.collector_api_port
  service_desired_count                   = var.collector_api_desired_count
  service_max_count                       = var.collector_api_max_count
  service_task_family                     = var.collector_api_task_family
  service_enviroment_variables = [
    {
      "name" : "AWS_REGION",
      "value" : "${tostring(var.aws_region)}",
    },
    {
      "name" : "AWS_KINESIS_TRANSACTIONS_STREAM_NAME",
      "value" : "${tostring(var.kinesis_stream_name)}",
    },
    {
      "name" : "AWS_KINESIS_FIREHOSE_TRANSACTIONS_DELIVERY_STREAM_NAME",
      "value" : "${tostring(var.kinesis_firehose_delivery_stream_name)}"
    }
  ]
  service_health_check_path  = var.collector_api_health_check_path
  network_mode               = var.collector_api_network_mode
  task_compatibilities       = var.collector_api_task_compatibilities
  launch_type                = var.collector_api_launch_type
  alb_listener               = module.public_alb.alb_listener
  has_alb                    = true
  alb_listener_tg            = var.collector_api_tg
  alb_listener_port          = 80
  alb_listener_protocol      = "HTTP"
  alb_listener_target_type   = "ip"
  alb_listener_arn           = module.public_alb.alb_listener_http_tcp_arn
  alb_listener_rule_priority = 1
  alb_listener_rule_type     = "forward"
  alb_service_tg_paths       = var.collector_api_tg_paths
  enable_autoscaling         = true
  autoscaling_name           = "${var.collector_api_name}_scaling"
  autoscaling_settings = {
    max_capacity       = 4
    min_capacity       = 2
    target_cpu_value   = 60
    scale_in_cooldown  = 60
    scale_out_cooldown = 900
  }
}

################################################################################
################################################################################
################################################################################
# S3 BUCKETS CONFIGURATION
################################################################################
################################################################################
################################################################################
resource "aws_s3_bucket" "transactions_bucket" {
  bucket        = "payment-transaction"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "transactions_bucket_acl" {
  bucket = aws_s3_bucket.transactions_bucket.id
  acl    = "private"
}

################################################################################
################################################################################
################################################################################
# KINESIS CONFIGURATION
################################################################################
################################################################################
################################################################################
resource "aws_kinesis_stream" "transactions_stream" {
  name             = var.kinesis_stream_name
  retention_period = 168

  shard_level_metrics = [
    "IncomingBytes",
    "IteratorAgeMilliseconds",
    "OutgoingBytes",
    "OutgoingRecords",
    "IncomingRecords",
    "ReadProvisionedThroughputExceeded",
    "WriteProvisionedThroughputExceeded"
  ]

  encryption_type = "NONE"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "transactions_s3_stream" {
  name        = var.kinesis_firehose_delivery_stream_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.transactions_stream.arn
    role_arn = aws_iam_role.firehose_role.arn
  }
  extended_s3_configuration {
    buffer_interval = 60
    buffer_size     = 1
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.transactions_bucket.arn

    # processing_configuration {
    #   enabled = "true"

    #   processors {
    #     type = "Lambda"

    #     parameters {
    #       parameter_name  = "LambdaArn"
    #       parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
    #     }
    #   }
    # }
  }
}

#Define a policy which will allow Kinesis Data Firehose to Assume an IAM Role
resource "aws_iam_role" "firehose_role" {
  name = "transactions_firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Define a policy which will allow Kinesis Data Firehose to access your S3 bucket
data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.transactions_bucket.arn,
      "${aws_s3_bucket.transactions_bucket.arn}/*",
    ]
  }
}

#attach s3 bucket access policy
resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  name   = "kinesis_firehose_access_bucket_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}

# Define a policy which will allow Kinesis Data Firehose to access your S3 bucket
data "aws_iam_policy_document" "kinesis_firehose_access_data_stream_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [
      aws_kinesis_stream.transactions_stream.arn
    ]
  }
}

# attach data stream access policy
resource "aws_iam_role_policy" "kinesis_firehose_access_data_stream_policy" {
  name   = "kinesis_firehose_access_data_stream_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_data_stream_assume_policy.json
}

################################################################################
################################################################################
################################################################################
# LAMBDAS CONFIGURATION
################################################################################
################################################################################
################################################################################
################################################################################
# Transactions Anomaly Detector
module "detect_anomaly_transactions" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "detect_transactions_anomalies"
  description   = "Detect new transaction anomaly"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../backend/serverless/transactions/detectAnomaly"

  store_on_s3 = true
  s3_bucket   = "bucket-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]

  event_source_mapping = {
    kinesis = {
      event_source_arn  = aws_kinesis_stream.transactions_stream.arn
      starting_position = "LATEST"
      filter_criteria = {
        pattern = jsonencode({
          data : {
            amount : [{ numeric : [">=", 1000] }]
          }
        })
      }
    }
  }

  allowed_triggers = {
    kinesis = {
      principal  = "kinesis.amazonaws.com"
      source_arn = aws_kinesis_stream.transactions_stream.arn
    }
  }

  attach_dead_letter_policy               = false
  create_current_version_allowed_triggers = false

  attach_network_policy    = true
  attach_policy_statements = true
  policy_statements = {
    secrets_manager_get_value = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.collector_database_password_secret.arn, aws_secretsmanager_secret.collector_database_username_secret.arn]
    }
  }
  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
  ]

  depends_on = [module.collector_database]

  environment_variables = {
    POSTGRES_HOST     = module.collector_database.db_instance_address,
    POSTGRES_PORT     = module.collector_database.db_instance_port,
    POSTGRES_DB       = module.collector_database.db_instance_name,
    POSTGRES_USER     = aws_secretsmanager_secret.collector_database_username_secret.arn,
    POSTGRES_PASSWORD = aws_secretsmanager_secret.collector_database_password_secret.arn,
  }
}
