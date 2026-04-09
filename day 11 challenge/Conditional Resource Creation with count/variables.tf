variable "enable_detailed_monitoring" {
  description = "Enable CloudWatch detailed monitoring (incurs additional cost)"
  type        = bool
  default     = false
}

variable "create_dns_record" {
  description = "Whether to create a Route53 DNS record for the ALB"
  type        = bool
  default     = false
}