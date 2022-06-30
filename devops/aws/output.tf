output "alb_url" {
  description = "Load balancer URL"
  value       = module.public_alb.alb_dns_name
}
