terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }

  required_version = ">= 1.0"
}