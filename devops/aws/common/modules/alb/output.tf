output "alb_id" {
  description = "The ID of the load balancer we created."
  value       = concat(aws_alb.this.*.id, [""])[0]
}

output "alb_arn" {
  description = "The ARN of the load balancer we created."
  value       = concat(aws_alb.this.*.arn, [""])[0]
}

output "alb_listener" {
  description = "The load balancer listener we created."
  value       = aws_alb_listener.http_tcp
}

output "alb_listener_http_tcp_arn" {
  description = "The ARN of the http alb listener we created."
  value       = concat(aws_alb_listener.http_tcp.*.arn, [""])[0]
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = concat(aws_alb.this.*.dns_name, [""])[0]
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = aws_alb_listener.http_tcp.*.arn
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = aws_alb_listener.http_tcp.*.id
}
