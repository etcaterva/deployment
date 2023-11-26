terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.25.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-2"
  profile                  = "default"
}

variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}
