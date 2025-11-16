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

variable "cloud_run_services" {
  description = "Map of Cloud Run services to create"
  type = map(object({
    image                 = string
    port                  = optional(number)
    cpu                   = optional(string)
    memory                = optional(string)
    min_instances         = optional(number)
    max_instances         = optional(number)
    max_concurrency       = optional(number)
    timeout               = optional(string)
    allow_unauthenticated = optional(bool)
    ingress               = optional(string)
    env_vars              = optional(map(string))
    labels                = optional(map(string))
    storage_buckets       = optional(list(string))
  }))
  default = {}
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
