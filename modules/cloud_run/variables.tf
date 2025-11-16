/******************************************
  Cloud Run Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "service_name" {
  description = "Service name (from for_each key)"
  type        = string
}

variable "service_config" {
  description = "Service configuration"
  type = object({
    image                 = string
    cpu                   = optional(string)
    memory                = optional(string)
    min_instances         = optional(number)
    max_instances         = optional(number)
    max_concurrency       = optional(number)
    timeout               = optional(string)
    allow_unauthenticated = optional(bool)
    ingress               = optional(string)
    env_vars              = optional(map(string))
    storage_bucket_key    = optional(string)
    image_blob_name       = optional(string)
    labels                = optional(map(string))
  })
}

variable "storage_bucket_name" {
  description = "Storage bucket name for IAM binding"
  type        = string
  default     = ""
}

/******************************************
  SSL Certificate Variables
******************************************/
variable "ssl_certificates" {
  description = "Managed SSL certificate configurations"
  type = map(object({
    domains = list(string)
  }))
  default = {}
}

/******************************************
  Load Balancer Variables
******************************************/
variable "load_balancers" {
  description = "Load balancer configurations"
  type = map(object({
    service_key      = string
    ssl_cert_key     = optional(string)
    enable_cdn       = optional(bool)
    session_affinity = optional(string)
    timeout_sec      = optional(number)
  }))
  default = {}
}
