# Lorem Ipsum Web Application

**Live Demo:** https://lorem-ipsum-app-360383538728.europe-west2.run.app

A minimal web application demonstrating Cloud Run deployment with Google Cloud Storage.

An addition to the code are the Load Balancer + SSL managed certificates and Cloud Run Failover (disabled by default),
showcasing a failover mechanism both for location and resource.


## Quick Deploy

### 1. Configure

```bash
# Authenticate with gcloud
gcloud auth login / gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 1.1. Create Terraform State Bucket

```bash
gsutil mb -l europe-west2 gs://terraform-state
gsutil versioning set on gs://terraform-state
```

### 2. Deploy Infrastructure

```bash
# From root
terraform init -backend-config=vars/prod_backend.tfvars
terraform apply -var-file=vars/prod.tfvars
```

### 3. Build & Push Container

```bash
# Built with the --platform flag, because I am using MacOS
cd app
docker buildx build --platform linux/amd64 \
  -t europe-west2-docker.pkg.dev/YOUR_PROJECT/lorem-ipsum/lorem-ipsum-app:latest \
  --push .
```

### 4. Upload Image

```bash
# Either manual or use commands below
gsutil cp static/lorem-ipsum.jpg gs://lorem-ipsum-assets/
gsutil acl ch -u AllUsers:R gs://lorem-ipsum-assets/lorem-ipsum.jpg
```

### 5. Redeploy

```bash
terraform apply -var-file=vars/prod.tfvars
```

## Tech Stack

- **Cloud Run**
- **Cloud Storage**
- **Artifact Registry**
- **Terraform**
- **Python Flask**

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_artifact_registry"></a> [artifact\_registry](#module\_artifact\_registry) | ./modules/artifact_registry | n/a |
| <a name="module_cloud_run"></a> [cloud\_run](#module\_cloud\_run) | ./modules/cloud_run | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_repositories"></a> [artifact\_repositories](#input\_artifact\_repositories) | Artifact Registry repositories configuration | <pre>map(object({<br/>    description = optional(string)<br/>    labels      = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_services"></a> [cloud\_run\_services](#input\_cloud\_run\_services) | Cloud Run services configuration | <pre>map(object({<br/>    image                  = string<br/>    cpu                    = optional(string)<br/>    memory                 = optional(string)<br/>    min_instances          = optional(number)<br/>    max_instances          = optional(number)<br/>    max_concurrency        = optional(number)<br/>    timeout                = optional(string)<br/>    allow_unauthenticated  = optional(bool)<br/>    ingress                = optional(string)<br/>    env_vars               = optional(map(string))<br/>    storage_bucket_key     = optional(string)<br/>    image_blob_name        = optional(string)<br/>    labels                 = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled_modules"></a> [enabled\_modules](#input\_enabled\_modules) | Toggle modules on/off | <pre>object({<br/>    artifact_registry = bool<br/>    storage           = bool<br/>    cloud_run         = bool<br/>  })</pre> | <pre>{<br/>  "artifact_registry": true,<br/>  "cloud_run": true,<br/>  "storage": true<br/>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"production"` | no |
| <a name="input_environment_code"></a> [environment\_code](#input\_environment\_code) | Environment code | `string` | `"prod"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for Cloud Run and Artifact Registry | `string` | `"europe-west2"` | no |
| <a name="input_storage_buckets"></a> [storage\_buckets](#input\_storage\_buckets) | Cloud Storage buckets configuration | <pre>map(object({<br/>    location                    = optional(string)<br/>    storage_class               = optional(string)<br/>    force_destroy               = optional(bool)<br/>    uniform_bucket_level_access = optional(bool)<br/>    versioning                  = optional(bool)<br/>    labels                      = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_location"></a> [storage\_location](#input\_storage\_location) | Default location for Cloud Storage buckets | `string` | `"EU"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_registry_urls"></a> [artifact\_registry\_urls](#output\_artifact\_registry\_urls) | Artifact Registry repository URLs |
| <a name="output_cloud_run_service_accounts"></a> [cloud\_run\_service\_accounts](#output\_cloud\_run\_service\_accounts) | Cloud Run service account emails |
| <a name="output_cloud_run_urls"></a> [cloud\_run\_urls](#output\_cloud\_run\_urls) | Cloud Run service URLs |
| <a name="output_storage_bucket_names"></a> [storage\_bucket\_names](#output\_storage\_bucket\_names) | Cloud Storage bucket names |
<!-- END_TF_DOCS -->