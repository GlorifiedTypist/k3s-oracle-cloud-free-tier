terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

provider "oci" {
  region              = var.region
  auth                = "SecurityToken"
  config_file_profile = "kubernetes"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/k3s"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/k3s"
}