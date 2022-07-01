output "aws_service_discovery_service_name" {
  description = "Defines service discovery name"
  value       = concat(aws_service_discovery_service.this.*.name, [""])[0]
}
