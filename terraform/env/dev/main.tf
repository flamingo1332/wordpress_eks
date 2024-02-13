terraform {
  cloud {
    organization = "ksw29555_personal_project"
    workspaces {
      name = "dev"
    }
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}