[
  {
    "name": "${service_name}",
    "image": "${image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "${network_mode}",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_logs_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port}
      }
    ],
    "environment": ${service_enviroment},
    "secrets": ${service_secrets}
  }
]
