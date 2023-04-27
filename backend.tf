terraform {
  backend "gcs" {
    bucket      = "gpu-vm-project-backend-state-storage"
    prefix      = "terraform/state"
    credentials = "/terraform/terraform-key"
  }
}
