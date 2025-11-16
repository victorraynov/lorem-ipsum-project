/******************************************
  General Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "primary_region" {
  description = "Primary region for Cloud Run"
  type        = string
  default     = "europe-west2"
}

variable "failover_region" {
  description = "Failover region for Cloud Run"
  type        = string
  default     = "us-central1"
}

variable "failover_enabled" {
  description = "Enable failover region deployment"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "environment_code" {
  description = "Environment code"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "europe-west2"
}

variable "storage_location" {
  description = "Storage location"
  type        = string
  default     = "europe-west2"
}

/******************************************
  Module Toggles
******************************************/
variable "enabled_modules" {
  description = "Toggle modules on/off"
  type = object({
    artifact_registry = optional(bool)
    storage           = bool
    cloud_run         = bool
    load_balancer     = bool
    ssl               = bool
  })
  default = {
    artifact_registry = false
    storage           = true
    cloud_run         = true
    load_balancer     = false
    ssl               = false
  }
}

/******************************************
  Storage Variables
******************************************/
variable "storage_buckets" {
  description = "Storage bucket configurations"
  type = map(object({
    location                    = optional(string)
    storage_class               = optional(string)
    force_destroy               = optional(bool)
    uniform_bucket_level_access = optional(bool)
    versioning                  = optional(bool)
    public_access               = optional(bool)
    labels                      = optional(map(string))
    cors = optional(object({
      origins          = optional(list(string))
      methods          = optional(list(string))
      response_headers = optional(list(string))
      max_age_seconds  = optional(number)
    }))
  }))
  default = {}
}

/******************************************
  Artifact Registry Variables
******************************************/
variable "artifact_repositories" {
  description = "Artifact Registry repositories"
  type = map(object({
    description = optional(string)
    labels      = optional(map(string))
  }))
  default = {}
}

/******************************************
  Cloud Run Variables
******************************************/
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
    storage_bucket_key    = optional(string)
    image_blob_name       = optional(string)
  }))
  default = {}
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