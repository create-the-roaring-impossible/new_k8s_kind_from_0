terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.52.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "random" {
  # Configuration options
  # https://registry.terraform.io/providers/hashicorp/random/latest/docs
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
  config_paths = [
    "~/.kube/config"
  ]
  config_context = "kind-personal-kind"
  insecure = true
}