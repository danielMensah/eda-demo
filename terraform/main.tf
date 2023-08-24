terraform {
  required_version = ">= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ezros"

    workspaces {
      prefix = "eda-demo-"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region

  default_tags {
    tags = module.tagging.tags
  }
}

locals {
  service_name = "eda-demo"
  table_name   = "eda-demo-table"
}

module "tagging" {
  source = "./modules/tagging"

  environment  = var.environment
  part_of      = local.service_name
  name         = local.service_name
  orchestrator = "Terraform"
  repository   = "https://github.com/danielMensah/${local.service_name}"
  component    = ""
}