/******************************************
  Service Account Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "account_id" {
  description = "Service account ID"
  type        = string
}

variable "service_account" {
  description = "Service account configuration"
  type = object({
    display_name = optional(string)
    description  = optional(string)
    roles        = optional(list(string))
  })
}
