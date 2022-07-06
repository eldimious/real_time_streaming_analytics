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

data "aws_partition" "current" {}
data "aws_region" "current" {}

# Sendgrid Secrets
resource "aws_secretsmanager_secret" "sendgrid_apikey_secret_manager" {
  name                    = "sendgrid_x_api_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sendgrid_apikey_secret_version" {
  secret_id     = aws_secretsmanager_secret.sendgrid_apikey_secret_manager.id
  secret_string = var.sendgrid_apikey
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
  project              = var.project
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

# VPC Flow Logs IAM
resource "aws_iam_role" "vpc_flow_cloudwatch_logs_role" {
  name               = "collector-vpc-flow-cloudwatch-logs-role"
  assume_role_policy = file("./common/templates/policies/vpc/vpc_flow_cloudwatch_logs_role.json.tpl")
}

resource "aws_iam_role_policy" "allow_vpc_flow_cloudwatch_logs_policy" {
  name   = "collector-vpc-flow-cloudwatch-logs-policy"
  role   = aws_iam_role.vpc_flow_cloudwatch_logs_role.id
  policy = file("./common/templates/policies/vpc/allow_vpc_flow_cloudwatch_logs_policy.json.tpl")
}

# VPC Flows
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
# DATABASES CONFIGURATION
################################################################################
################################################################################
################################################################################
# Databases Secrets
resource "aws_secretsmanager_secret" "db_collector_password_secret_manager" {
  name                    = "db_collector_master_password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_collector_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_collector_password_secret_manager.id
  secret_string = var.collector_database_password
}

resource "aws_secretsmanager_secret" "db_collector_username_secret_manager" {
  name                    = "db_collector_master_username"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_collector_username_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_collector_username_secret_manager.id
  secret_string = var.collector_database_username
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
# data kinesis stream
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

# firehose kinesis stream
resource "aws_kinesis_firehose_delivery_stream" "transactions_s3_stream" {
  name        = var.kinesis_firehose_delivery_stream_name
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.transactions_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
  extended_s3_configuration {
    buffer_interval = 60
    buffer_size     = 1
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.transactions_bucket.arn
  }
}

# Define a policy which will allow Kinesis Data Firehose to Assume an IAM Role
resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
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

# Define a policy which will allow Kinesis Data Firehose to access your S3 bucket
data "aws_iam_policy_document" "allow_firehose_access_bucket_policy" {
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

# Define a policy which will allow Kinesis Data Firehose to access your S3 bucket
data "aws_iam_policy_document" "allow_firehose_access_data_stream_policy" {
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

# attach s3 bucket access policy
resource "aws_iam_role_policy" "allow_firehose_access_bucket_policy" {
  name   = "allow_firehose_access_bucket_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.allow_firehose_access_bucket_policy.json
}

# attach data stream access policy
resource "aws_iam_role_policy" "allow_firehose_access_data_stream_policy" {
  name   = "allow_firehose_access_data_stream_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.allow_firehose_access_data_stream_policy.json
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
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

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
      event_source_arn                   = aws_kinesis_stream.transactions_stream.arn
      starting_position                  = "LATEST"
      batch_size                         = 10
      maximum_batching_window_in_seconds = 60
      # TODO: make filter criteria to work and invoke lambda only on the following specific case
      # filter_criteria = {
      #   pattern = jsonencode({
      #     data : {
      #       amount : [{ numeric : [">", 1000] }]
      #     }
      #   })
      # }
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
      effect  = "Allow",
      actions = ["secretsmanager:GetSecretValue"],
      resources = [
        aws_secretsmanager_secret.db_collector_password_secret_manager.arn,
        aws_secretsmanager_secret.db_collector_username_secret_manager.arn,
        aws_secretsmanager_secret.sendgrid_apikey_secret_manager.arn
      ]
    }
  }

  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
  ]

  depends_on = [module.collector_database]

  # TODO: get POSTGRES_USER / POSTGRES_PASSWORD / SENDGRID_API_KEY from aws_secretsmanager_secret
  environment_variables = {
    POSTGRES_HOST     = module.collector_database.db_instance_address,
    POSTGRES_PORT     = module.collector_database.db_instance_port,
    POSTGRES_DB       = module.collector_database.db_instance_name,
    POSTGRES_USER     = var.collector_database_username,
    POSTGRES_PASSWORD = var.collector_database_password,
    SENDGRID_API_KEY  = var.sendgrid_apikey,
    SENDER_EMAIL      = var.sendgrid_sender_email,
    RECEIVER_EMAIL    = var.sendgrid_receiver_email
  }
}

################################################################################
# HELPER Lambdas
################################################################################
module "run_db_migrations" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "run_db_migrations"
  description   = "Run database migrations"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../backend/serverless/helper/database/runMigrations"

  store_on_s3 = true
  s3_bucket   = "bucket-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secrets_manager_get_value = {
      effect  = "Allow",
      actions = ["secretsmanager:GetSecretValue"],
      resources = [
        aws_secretsmanager_secret.db_collector_password_secret_manager.arn,
        aws_secretsmanager_secret.db_collector_username_secret_manager.arn,
        aws_secretsmanager_secret.sendgrid_apikey_secret_manager.arn
      ]
    }
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main_api_gw.execution_arn}/*/*/*"
    }
  }

  attach_dead_letter_policy = false

  depends_on = [module.collector_database]

  # TODO: get POSTGRES_USER / POSTGRES_PASSWORD / SENDGRID_API_KEY from aws_secretsmanager_secret
  environment_variables = {
    POSTGRES_HOST     = module.collector_database.db_instance_address,
    POSTGRES_PORT     = module.collector_database.db_instance_port,
    POSTGRES_DB       = module.collector_database.db_instance_name,
    POSTGRES_USER     = var.collector_database_username,
    POSTGRES_PASSWORD = var.collector_database_password
  }
}

################################################################################
# AUTH Lambdas
################################################################################
module "basic_auth" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "basic_auth"
  description   = "Verifies basic authentication"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../backend/serverless/auth/verifyBasicAuth"

  store_on_s3 = true
  s3_bucket   = "bucket-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy  = true

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main_api_gw.execution_arn}/*/*/*"
    }
  }

  attach_dead_letter_policy = false

  environment_variables = {
    BASIC_AUTH_USERNAME = var.basic_auth_username
    BASIC_AUTH_PASSWORD = var.basic_auth_password
  }
}

################################################################################
################################################################################
################################################################################
# API GW CONFIGURATION
################################################################################
################################################################################
################################################################################
# API Gateway
resource "aws_api_gateway_rest_api" "main_api_gw" {
  name           = "main-GW"
  api_key_source = "HEADER"
  tags = {
    Name = "http-apigateway"
  }
}

# given API Gateway the requisite permissions in order to write logs to CloudWatch
resource "aws_api_gateway_account" "api_gw_account" {
  cloudwatch_role_arn = aws_iam_role.api_gw_role.arn
}

resource "aws_iam_role" "api_gw_role" {
  name               = "api_gw_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "allow_api_gw_invoke_cloudwatch_policy" {
  name   = "allow_api_gw_invoke_cloudwatch_policy"
  role   = aws_iam_role.api_gw_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "allow_api_gw_invoke_kinesis_policy" {
  statement {
    sid = "PutRecord"
    actions = [
      "kinesis:PutRecord",
    ]
    effect = "Allow"
    resources = [
      aws_kinesis_stream.transactions_stream.arn
    ]
  }

  statement {
    sid = "PutRecords"
    actions = [
      "kinesis:PutRecords"
    ]
    effect = "Allow"
    resources = [
      aws_kinesis_stream.transactions_stream.arn
    ]
  }
}

# attach api gw kinesis access policy to aws_iam_role.api_gw_role
resource "aws_iam_role_policy" "allow_api_gw_invoke_kinesis_policy" {
  name   = "api_gw_kinesis_invocation_policy"
  role   = aws_iam_role.api_gw_role.name
  policy = data.aws_iam_policy_document.allow_api_gw_invoke_kinesis_policy.json
}

# attach api gw basic auth lambda invocation policy to aws_iam_role.api_gw_role
resource "aws_iam_role_policy" "allow_api_gw_invoke_basic_auth_lambda_policy" {
  name = "allow_api_gw_invoke_basic_auth_lambda_policy"
  role = aws_iam_role.api_gw_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.basic_auth.lambda_function_arn}"
    }
  ]
}
EOF
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.databases.id,
      aws_api_gateway_resource.migrations.id,
      aws_api_gateway_method.run_migrations.id,
      aws_api_gateway_integration.run_migrations_integration.id,
      aws_api_gateway_resource.collector.id,
      aws_api_gateway_resource.transactions.id,
      aws_api_gateway_method.create_transactions.id,
      aws_api_gateway_integration.create_transactions_integration.id,
    ]))
  }
  # use depends_on to ensure that the deployment occurs after all dependencies are created
  depends_on = [
    aws_api_gateway_integration.run_migrations_integration,
    aws_api_gateway_method.run_migrations,
    aws_api_gateway_integration.create_transactions_integration,
    aws_api_gateway_method.create_transactions
  ]
}

resource "aws_api_gateway_stage" "api_gw_prod_stage" {
  rest_api_id   = aws_api_gateway_rest_api.main_api_gw.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id
  # Bug in terraform-aws-provider with perpetual diff
  # lifecycle {
  #   ignore_changes = [deployment_id]
  # }
}

resource "aws_api_gateway_usage_plan" "api_gw_usage_plan" {
  name = "api_gw_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.main_api_gw.id
    stage  = aws_api_gateway_stage.api_gw_prod_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "api_gw_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_gw_prod_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_gw_usage_plan.id
}

resource "aws_api_gateway_api_key" "api_gw_prod_api_key" {
  name        = "api_gw_prod_api_key"
  description = "api key used to make requests to api"
  enabled     = true
}

# /databases/migrations
resource "aws_api_gateway_resource" "databases" {
  path_part   = "databases"
  parent_id   = aws_api_gateway_rest_api.main_api_gw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
}

resource "aws_api_gateway_resource" "migrations" {
  path_part   = "migrations"
  parent_id   = aws_api_gateway_resource.databases.id
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
}

resource "aws_api_gateway_method" "run_migrations" {
  rest_api_id      = aws_api_gateway_rest_api.main_api_gw.id
  resource_id      = aws_api_gateway_resource.migrations.id
  http_method      = "POST"
  api_key_required = true
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.basic_auth.id
}

resource "aws_api_gateway_integration" "run_migrations_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main_api_gw.id
  resource_id             = aws_api_gateway_resource.migrations.id
  http_method             = aws_api_gateway_method.run_migrations.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  connection_type         = "INTERNET"
  timeout_milliseconds    = 12000
  uri                     = module.run_db_migrations.lambda_function_invoke_arn
}

# /collector/transactions
resource "aws_api_gateway_resource" "collector" {
  path_part   = "collector"
  parent_id   = aws_api_gateway_rest_api.main_api_gw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
}

resource "aws_api_gateway_resource" "transactions" {
  path_part   = "transactions"
  parent_id   = aws_api_gateway_resource.collector.id
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
}

resource "aws_api_gateway_method" "create_transactions" {
  rest_api_id      = aws_api_gateway_rest_api.main_api_gw.id
  resource_id      = aws_api_gateway_resource.transactions.id
  http_method      = "POST"
  api_key_required = true
  authorization    = "NONE"
}

resource "aws_api_gateway_method_response" "create_transactions_200" {
  rest_api_id = aws_api_gateway_rest_api.main_api_gw.id
  resource_id = aws_api_gateway_resource.transactions.id
  http_method = aws_api_gateway_method.create_transactions.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

resource "aws_api_gateway_integration" "create_transactions_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main_api_gw.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.create_transactions.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  timeout_milliseconds    = 12000

  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/PutRecords",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )
  connection_type = "INTERNET"
  credentials     = aws_iam_role.api_gw_role.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }
  request_templates = {
    "application/json" = <<EOT
    {
      "StreamName": "${var.kinesis_stream_name}",
      "Records": [
        #foreach($elem in $input.path('$.records'))
        #set($event = "{
          ""trxId"":""$elem.trxId"",
          ""amount"":""$elem.amount"",
          ""senderId"":""$elem.senderId"",
          ""receiverId"":""$elem.receiverId"",
          ""senderIban"":""$elem.senderIban"",
          ""receiverIban"":""$elem.receiverIban"",
          ""senderBankId"":""$elem.senderBankId"",
          ""receiverBankId"":""$elem.receiverBankId"",
          ""transactionDate"":""$elem.transactionDate""
        }")
        {
          "Data": "$util.base64Encode($event)",
          "PartitionKey": "$elem.trxId"
        }#if($foreach.hasNext),#end
        #end
      ]
    }
    EOT
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_integration_response" "create_transactions" {
  rest_api_id         = aws_api_gateway_rest_api.main_api_gw.id
  resource_id         = aws_api_gateway_resource.transactions.id
  http_method         = aws_api_gateway_method.create_transactions.http_method
  status_code         = aws_api_gateway_method_response.create_transactions_200.status_code
  response_parameters = {}
}

resource "aws_api_gateway_authorizer" "basic_auth" {
  name                   = "BasicAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.main_api_gw.id
  type                   = "REQUEST"
  identity_source        = "method.request.header.Authorization"
  authorizer_uri         = module.basic_auth.lambda_function_invoke_arn
  authorizer_credentials = aws_iam_role.api_gw_role.arn
}
