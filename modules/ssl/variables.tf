/******************************************
  SSL Module Variables
******************************************/
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cert_name" {
  description = "Certificate name"
  type        = string
}

variable "cert_config" {
  description = "Certificate configuration"
  type = object({
    domains = list(string)
  })
}
