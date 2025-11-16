/******************************************
  Managed SSL Certificate
******************************************/
resource "google_compute_managed_ssl_certificate" "cert" {
  name = var.cert_name

  managed {
    domains = var.cert_config.domains
  }
}
