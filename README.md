# Deploy Delta Sharing Server OSS - Terraform Template


## Introduction

This repository implements specific feature to access data using delta sharing from data sources exposing S3 compatible APIs such as Palantir Foundry.

## Getting Started

1. Clone this Repo
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
3. Fill out `parameters.tfvars`
4. Configure the [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
5. Run `terraform init`
6. Run `terraform validate`
7.  Run `terraform apply -var-file ./parameters/parameters.tfvars`


## Diagram 
![Architecture Diagram](https://github.com/elghali97/terraform-infrastructure-delta-sharing-server/blob/master/diagram.png)