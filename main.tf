# Creates a new project + basics in gcp
module "gcp-tf-base" {
  organization    = var.organization
  organization_id = var.organization_id
  billing_account = var.billing_account

  main_availability_zone = var.main_availability_zone
  location               = var.location

  project_name = var.project_name
  project_id   = var.project_id

  keyring     = var.keyring
  keyring_key = var.keyring_key

  big_robot_group = var.big_robot_group
  big_robot_name  = var.big_robot_name
  big_robot_email = var.big_robot_email

  # State bucket
  backend_bucket_name = var.backend_bucket_name
  bucket_path_prefix  = var.bucket_path_prefix
}
