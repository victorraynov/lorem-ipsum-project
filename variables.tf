/******************************************
  General Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run and Artifact Registry"
  type        = string
  default     = "europe-west2"
}

variable "storage_location" {
  description = "Default location for Cloud Storage buckets"
  type        = string
  default     = "EU"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "environment_code" {
  description = "Environment code"
  type        = string
}

/******************************************
  Module Toggles
******************************************/
variable "enabled_modules" {
  description = "Toggle modules on/off"
  type = object({
    artifact_registry = bool
    storage           = bool
    cloud_run         = bool
  })
  default = {
    artifact_registry = true
    storage           = true
    cloud_run         = true
    load_balancer     = true
    ssl               = true
  }
}

/******************************************
  Artifact Registry Variables
******************************************/
variable "artifact_repositories" {
  description = "Artifact Registry repositories configuration"
  type = map(object({
    description = optional(string)
    labels      = optional(map(string))
  }))
  default = {}
}

/******************************************
  Cloud Storage Variables
******************************************/
variable "storage_buckets" {
  description = "Cloud Storage buckets configuration"
  type = map(object({
    location                    = optional(string)
    storage_class               = optional(string)
    force_destroy               = optional(bool)
    uniform_bucket_level_access = optional(bool)
    versioning                  = optional(bool)
    labels                      = optional(map(string))
  }))
  default = {}
}

/******************************************
  Cloud Run Variables
******************************************/
variable "cloud_run_services" {
  description = "Cloud Run services configuration"
  type = map(object({
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
  }))
  default = {}
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
