terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      version = ">= 5.48.0"
      source  = "hashicorp/aws"
    }
    awscc = {
      version = ">= 0.76.0"
      source  = "hashicorp/awscc"
    }
    local = {
      version = ">= 2.5.1"
      source  = "hashicorp/local"
    }
    onepassword = {
      version = ">= 1.4.3"
      source  = "1Password/onepassword"
    }
    random = {
      version = ">= 3.6.1"
      source  = "hashicorp/random"
    }
  }
}
