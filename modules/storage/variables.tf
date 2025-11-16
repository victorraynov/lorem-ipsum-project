/******************************************
  Storage Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Bucket location"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name (from for_each key)"
  type        = string
}

variable "bucket" {
  description = "Bucket configuration"
  type = object({
    location                    = optional(string)
    storage_class               = optional(string)
    force_destroy               = optional(bool)
    uniform_bucket_level_access = optional(bool)
    versioning                  = optional(bool)
    labels                      = optional(map(string))
  })
}
