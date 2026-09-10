output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet identifiers."
  value       = aws_subnet.public[*].id
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins controller."
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins web interface."
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_webhook_url" {
  description = "Payload URL for the GitHub webhook. The trailing slash is required."
  value       = "http://${aws_instance.jenkins.public_ip}:8080/github-webhook/"
}

output "jenkins_role_arn" {
  description = "IAM role assumed by Jenkins, mapped into the cluster via an access entry."
  value       = aws_iam_role.jenkins.arn
}

output "jenkins_unlock_command" {
  description = "Retrieve the initial admin password without opening SSH."
  value       = "aws ssm start-session --target ${aws_instance.jenkins.id} --region ${var.aws_region}"
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the control plane."
  value       = aws_eks_cluster.this.version
}

output "configure_kubectl" {
  description = "Command that writes the kubeconfig entry for this cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}"
}

output "account_id" {
  description = "AWS account hosting these resources."
  value       = data.aws_caller_identity.current.account_id
}
