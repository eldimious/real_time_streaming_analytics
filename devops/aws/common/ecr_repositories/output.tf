output "ecr_registry_urls" {
  description = "Contains the urls of the ecr repositories"
  value       = values(module.ecr)[*].repository_url
}
