/******************************************
  GCP Configuration
******************************************/
environment      = "production"
environment_code = "prod"
project_id       = "studious-camp-478213-k4"
region           = "europe-west2"
storage_location = "europe-west2"
failover_region  = "us-central1"

/******************************************
  Module Toggles
******************************************/
failover_enabled = false
enabled_modules = {
  artifact_registry = true
  storage           = true
  cloud_run         = true
  load_balancer     = false
  ssl               = false
}

/******************************************
  Artifact Registry
******************************************/
artifact_repositories = {
  lorem-ipsum = {
    description = "Docker repository for Lorem Ipsum application"
    labels = {
      app         = "lorem-ipsum"
      environment = "production"
      managed-by  = "terraform"
    }
  }
}

/******************************************
  Cloud Storage Buckets
******************************************/
storage_buckets = {
  lorem-ipsum-assets = {
    location                    = "europe-west2"
    storage_class               = "STANDARD"
    force_destroy               = true
    uniform_bucket_level_access = false
    versioning                  = false

    labels = {
      app         = "lorem-ipsum"
      environment = "production"
      type        = "static-assets"
      managed-by  = "terraform"
    }
  }
}

/******************************************
  Cloud Run Services
******************************************/
cloud_run_services = {
  lorem-ipsum-app = {
    image = "europe-west2-docker.pkg.dev/studious-camp-478213-k4/lorem-ipsum/lorem-ipsum-app:latest"

    cpu    = "1"
    memory = "512Mi"

    min_instances = 0
    max_instances = 10

    max_concurrency = 80
    timeout         = "300s"

    allow_unauthenticated = true
    ingress               = "INGRESS_TRAFFIC_ALL"

    storage_bucket_key = "lorem-ipsum-assets"
    image_blob_name    = "lorem-ipsum.jpg"

    env_vars = {
      ENVIRONMENT = "production"
    }

    labels = {
      app         = "lorem-ipsum"
      environment = "production"
      managed-by  = "terraform"
    }
  }
  # lorem-ipsum-app-2 = {
  #   image = "europe-west2-docker.pkg.dev/studious-camp-478213-k4/lorem-ipsum/lorem-ipsum-app:latest"
  #
  #   cpu    = "1"
  #   memory = "512Mi"
  #
  #   min_instances = 0
  #   max_instances = 10
  #
  #   max_concurrency = 80
  #   timeout         = "300s"
  #
  #   allow_unauthenticated = true
  #   ingress               = "INGRESS_TRAFFIC_ALL"
  #
  #   storage_bucket_key = "lorem-ipsum-assets"
  #   image_blob_name    = "lorem-ipsum.jpg"
  #
  #   env_vars = {
  #     ENVIRONMENT = "production"
  #   }
  #
  #   labels = {
  #     app         = "lorem-ipsum"
  #     environment = "production"
  #     managed-by  = "terraform"
  #   }
  # }
}

/******************************************
  SSL Certificates
******************************************/
ssl_certificates = {
  lorem-ipsum-cert = {
    domains = ["dummydomain.com", "www.dummydomain.com"]
  }
}

/******************************************
  Global Load Balancer
******************************************/
load_balancers = {
  lorem-ipsum-lb = {
    service_key      = "lorem-ipsum-app"
    ssl_cert_key     = "lorem-ipsum-cert"
    enable_cdn       = true
    session_affinity = "NONE"
    timeout_sec      = 30
  }
}
