# output "x_api_key" {
#   description = "api key used to make requests to api"
#   value       = resource.aws_api_gateway_api_key.api_gw_prod_api_key.value
#   sensitive = true
# }

output "api_gateway_url" {
  value = "${aws_api_gateway_stage.api_gw_prod_stage.invoke_url}"
}