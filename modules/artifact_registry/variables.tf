/******************************************
  Artifact Registry Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Repository location"
  type        = string
}

variable "repository_id" {
  description = "Repository ID (from for_each key)"
  type        = string
}

variable "repository" {
  description = "Repository configuration"
  type = object({
    description = optional(string)
    labels      = optional(map(string))
  })
}
