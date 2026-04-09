locals {
  instance_type    = var.environment == "production" ? "t2.medium" : "t2.micro"
  min_cluster_size = var.environment == "production" ? 3 : 1
  max_cluster_size = var.environment == "production" ? 10 : 3
}

resource "aws_instance" "web" {
  instance_type = local.instance_type
  ami = "ami-0c02fb55956c7d316"
}