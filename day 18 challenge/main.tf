# modules/services/webserver_cluster
variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "instance_type" {
  type        = string
  description = "The instance type for the EC2 instance"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in the ASG"
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the ASG"
}

variable "environment" {
  type        = string
  description = "The environment for the resources (e.g., dev, staging, prod)"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

resource "aws_security_group" "web_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for ${var.cluster_name}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
