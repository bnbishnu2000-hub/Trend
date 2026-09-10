variable "aws_region" {
  description = "Region hosting all resources."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Prefix applied to resource names."
  type        = string
  default     = "trend"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "trend-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets, one per availability zone. Worker nodes run here; private subnets would require a NAT gateway, which is billed hourly and outside the free tier."
  type        = list(string)
  default     = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19"]
}

variable "admin_cidr" {
  description = "Address permitted to reach SSH and the Jenkins UI. Obtain with: curl -s https://checkip.amazonaws.com"
  type        = string

  validation {
    condition     = var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must not be 0.0.0.0/0. Supply a specific address."
  }
}

variable "github_webhook_cidrs" {
  description = "Source ranges allowed to reach Jenkins on 8080 for webhook delivery. Refresh with: curl -s https://api.github.com/meta | jq -r '.hooks[]'"
  type        = list(string)
  default = [
    "192.30.252.0/22",
    "185.199.108.0/22",
    "140.82.112.0/20",
    "143.55.64.0/20",
  ]
}

variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins controller. t3.micro is used because the account is on a restricted free-tier plan permitting only free-tier-eligible types; 1 GiB of RAM requires a swap file to build images reliably."
  type        = string
  default     = "t3.micro"
}

variable "jenkins_root_volume_size" {
  description = "Root volume size in GiB. Docker layers consume this quickly."
  type        = number
  default     = 30
}

variable "key_name" {
  description = "Existing EC2 key pair name. Empty relies on SSM Session Manager."
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS control plane version."
  type        = string
  default     = "1.34"
}

variable "node_instance_types" {
  description = "Instance types for the managed node group. t3.micro allows only 4 pods per node because of the ENI address limit."
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 3
}
