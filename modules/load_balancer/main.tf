/******************************************
  Global Load Balancer with Failover
******************************************/

resource "google_compute_backend_service" "default" {
  name                  = "${var.lb_name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = try(var.lb_config.timeout_sec, 30)
  enable_cdn            = try(var.lb_config.enable_cdn, false)
  session_affinity      = try(var.lb_config.session_affinity, "NONE")
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = var.primary_neg
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    description     = "Primary region backend (${var.primary_region})"
  }

  backend {
    group           = var.failover_neg
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    description     = "Failover region backend (${var.failover_region})"
    failover        = true
  }

  health_checks = [google_compute_health_check.default.id]

  failover_policy {
    disable_connection_drain_on_failover = false
    drop_traffic_if_unhealthy            = true
    failover_ratio                       = 1.0
  }
}

resource "google_compute_health_check" "default" {
  name               = "${var.lb_name}-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_target_https_proxy" "default" {
  count = var.ssl_cert_id != null ? 1 : 0

  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [var.ssl_cert_id]
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.lb_name}-http"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
}

resource "google_compute_global_forwarding_rule" "https" {
  count = var.ssl_cert_id != null ? 1 : 0

  name                  = "${var.lb_name}-https"
  target                = google_compute_target_https_proxy.default[0].id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
}
