/******************************************
  Cloud Function Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "function_name" {
  description = "Function name"
  type        = string
}

variable "function_config" {
  description = "Function configuration"
  type = object({
    description           = optional(string)
    runtime               = optional(string)
    entry_point           = optional(string)
    source_dir            = optional(string)
    available_memory      = optional(string)
    timeout               = optional(number)
    max_instances         = optional(number)
    min_instances         = optional(number)
    ingress_settings      = optional(string)
    service_account_key   = optional(string)
    environment_variables = optional(map(string))
  })
}

variable "service_account" {
  description = "Service account email"
  type        = string
  default     = ""
}
