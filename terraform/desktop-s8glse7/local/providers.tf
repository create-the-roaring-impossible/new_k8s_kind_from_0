terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.19.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.51.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "aws" {
  # Configuration options
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
}

provider "azurerm" {
  # Configuration options
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
}

provider "google" {
  # Configuration options
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs
}

provider "kubernetes" {
  # Configuration options
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
  # config_paths = [
  #   "/path/to/config_a.yaml"
  # ]
  # config_context = "my-context"
}