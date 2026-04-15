variables {
  cluster_name  = "test-cluster"
  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
  min_size      = 2
  max_size      = 5
  environment   = "dev"
  project_name  = "test-project"
}

run "validate_cluster_name" {
  command = plan

  assert {
    condition     = var.cluster_name != ""
    error_message = "cluster name can not be empty"
  }
}

run "validate_security_group" {
  command = plan

  assert {
    condition     = length(aws_security_group.web_sg) > 0
    error_message = "security group must be created"
  }
}
