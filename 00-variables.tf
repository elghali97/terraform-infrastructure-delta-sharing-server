# ================================================================================================================
# Variables
# ================================================================================================================

// ----------- GLOBAL -----------
variable "region" {
  type        = string
  description = "(Required) The location for the resources in this module"
  default     = "eu-west-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "(Required) The availability zones for the resources in this module"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "environment" {
  type        = string
  description = "(Required) The environment name for the deployment"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "project_short_name" {
  type        = string
  description = "(Required) The short name of the project associated with the infrastructure to be managed by Terraform"
}

// ----------- VPC -----------
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

// ----------- VPC -----------
variable "palantir_access_key_id" {
  type    = string
  description = "(Required) The Access Key to access data from Palantir Foundry"
}

variable "palantir_secret_access_key" {
  type    = string
  description = "(Required) The Secret Access Key to access data from Palantir Foundry"
}

variable "palantir_endpoint" {
  type    = string
  description = "(Required) The S3 endpoint to be used to access Palantir data"
}

variable "palantir_region" {
  type    = string
  description = "(Required) The Palantir region"
  default = "palantir"
}

variable "palantir_dataset_name" {
  type    = string
  description = "(Required) The Palantir Foundry Dataset Name"
}

variable "palantir_dataset_id" {
  type    = string
  description = "(Required) The Palantir Foundry Dataset Resource Identifier"
}

// ----------- LOCALS -----------
locals {
  tags = {
    "databricks:deployment"  = "terraform",
    "databricks:region"      = var.region,
    "databricks:environment" = var.environment,
    "databricks:project"     = var.project_name,
    "databricks:short-name"  = var.project_short_name,
  }

  databricks_control_plane_ips = {
    "ap-northeast-1" = ["35.72.28.0/28", "18.177.16.95/32"],
    "ap-northeast-2" = ["3.38.156.176/28", "54.180.50.119/32"],
    "ap-south-1"     = ["65.0.37.64/28", " 13.232.248.161/32"],
    "ap-southeast-1" = ["13.214.1.96/28", "13.213.212.4/32"],
    "ap-southeast-2" = ["3.26.4.0/28", "13.237.96.217/32"],
    "ca-central-1"   = ["3.96.84.208/28", "35.183.59.105/32"],
    "eu-central-1"   = ["18.159.44.32/28", "18.159.32.64/32"],
    "eu-west-1"      = ["3.250.244.112/28", "46.137.47.49/32"],
    "eu-west-2"      = ["18.134.65.240/28", "3.10.112.150/32"],
    "eu-west-3"      = ["13.39.141.128/28", "15.236.174.74/32"],
    "sa-east-1"      = ["15.229.120.16/28", "177.71.254.47/32"],
    "us-east-1"      = ["3.237.73.224/28", "54.156.226.103/32"],
    "us-east-2"      = ["3.128.237.208/28", "18.221.200.169/32"],
    "us-west-1"      = ["44.234.192.32/28", "52.27.216.188/32"],
    "us-west-2"      = ["44.234.192.32/28", "52.27.216.188/32"],
  }

}