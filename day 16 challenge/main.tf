#refactor of infrastructure to use modules and variables
locals {
  common_tags={
    Environment = var.environment
    ManagedBy = "terraform"
    Project = var.project_name
    owner = var.team_name
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web"
  })
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
 alarm_name = "${var.project_name}-high-cpu"
 comparison_operator = "GreaterThanThreshold"
 evaluation_periods = 2
 metric_name = "CPUUtilization"
 namespace = "AWS/EC2"
 period = 120
 statistic = "Average"
 threshold = 80
 alarm_description = "This metric monitors high CPU utilization"
 alarm_actions = [aws_sns_topic.alerts.arn]

 dimensions = {
   InstanceId = aws_instance.web.id
 }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
  
}

#input validation for variables
variable "environment" {
    type = string
    description = "The environment for the resources (e.g., dev, staging, prod)"
    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "The environment must be one of: dev, staging, or prod."
    }
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "team_name" {
  type        = string
  description = "The name of the team that owns the resources"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
    type = string
    description = "The instance type for the EC2 instance"
    validation {
        condition = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
        error_message = "The instance type must be one of: t2.micro, t2.small, or t2.medium."
    }
}