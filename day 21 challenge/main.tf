#sentinel policies
#sentinel /require-instance-type.sentinel   
#sentinel /require-tags.sentinel    
terraform {
  required_version = ">= 0.12"
}
provider "aws" {
  region = "us-east-1"
}

import "tfplan/v2" as tfplan

allowed_instance_types = ["t2.micro", "t2.small", "t2.medium"]

rule "require-instance-type" {
  if tfplan.is_create {
    all resource.aws_instance as instance {
      instance.type in allowed_instance_types
    }
  }
}
