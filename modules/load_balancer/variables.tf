/******************************************
  Load Balancer Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "lb_name" {
  description = "Load balancer name"
  type        = string
}

variable "lb_config" {
  description = "Load balancer configuration"
  type = object({
    service_key      = string
    ssl_cert_key     = optional(string)
    enable_cdn       = optional(bool)
    session_affinity = optional(string)
    timeout_sec      = optional(number)
  })
}

variable "primary_neg" {
  description = "Primary region NEG ID"
  type        = string
}

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "failover_neg" {
  description = "Failover region NEG ID"
  type        = string
}

variable "failover_region" {
  description = "Failover region"
  type        = string
}

variable "ssl_cert_id" {
  description = "SSL certificate ID"
  type        = string
  default     = null
}
