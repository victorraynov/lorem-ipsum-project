/******************************************
  Firestore Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Firestore location"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database" {
  description = "Database configuration"
  type = object({
    type                        = optional(string)
    concurrency_mode            = optional(string)
    app_engine_integration_mode = optional(string)
  })
}
