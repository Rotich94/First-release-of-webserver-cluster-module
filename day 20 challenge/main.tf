#terraform cloud workspace configuration
terraform {
  required_version = ">= 1.1.0"
  cloud {
    organization = "test-94"
    workspaces {
      name = "test-1"
    }
  }
}