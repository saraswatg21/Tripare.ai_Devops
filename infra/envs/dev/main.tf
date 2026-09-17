terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "ecs_image" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_backup_retention" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}

module "network" {
  source = "../../modules/network"
  name   = "tripare-dev"

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecs" {
  source = "../../modules/ecs"
  name   = "tripare-dev"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  image              = var.ecs_image
}

module "rds" {
  source = "../../modules/rds"
  name   = "tripare-dev-db"

  subnet_ids              = module.network.private_subnet_ids
  vpc_id                  = module.network.vpc_id
  ecs_security_group_id   = module.ecs.ecs_security_group_id
  instance_class          = var.rds_instance_class
  backup_retention_period = var.rds_backup_retention
  deletion_protection     = var.rds_deletion_protection
}

