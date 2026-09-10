terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # Local state is used here. For collaborative or production use, move state
  # to S3 with DynamoDB locking so concurrent applies cannot corrupt it.
  # backend "s3" {
  #   bucket         = "trend-tfstate-401905376866"
  #   key            = "trend/terraform.tfstate"
  #   region         = "eu-north-1"
  #   dynamodb_table = "trend-tf-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
