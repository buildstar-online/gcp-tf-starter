module "gcp-tf-base" {

  source = "github.com/cloudymax/modules-gcp-tf-base.git"

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

module "gcp-tf-vm" {

  source = "github.com/cloudymax/modules-gcp-tf-vm.git"

  project_id                  = var.project_id
  location                    = var.location
  main_availability_zone      = var.main_availability_zone
  big_robot_email             = var.big_robot_email
  machine_type                = "n1-standard-8"
  guest_accelerator           = "nvidia-tesla-p100"
  guest_accelerator_count     = 1
  provisioning_model          = "SPOT"
  instance_termination_action = "STOP"
  os_image                    = "ubuntu-os-cloud/ubuntu-2204-lts"
  disk_type                   = "pd-ssd"
  disk_size                   = var.disk_size
}

/*
module "modules-gcp-gke" {

  source = "https://github.com/cloudymax/modules-gcp-gke.git"

  cluster_name            = var.cluster_name
  use_default_node_pool   = var.use_default_node_pool
  initial_node_count      = var.initial_node_count
  disk_type               = var.disk_type
  machine_type            = var.machine_type
  autoscaling_enabled     = var.autoscaling_enabled

  autoscaling_max_mem     = var.autoscaling_max_mem
  autoscaling_strategy    = var.autoscaling_strategy
  autoscaling_min_mem     = var.autoscaling_min_mem
  autoscaling_min_cpu     = var.autoscaling_min_cpu
  autoscaling_max_cpu     = var.autoscaling_max_cpu
  node_service_account    = var.terraform_robot_email

  container_name          = var.container_name
  container_image         = var.container_image
  region                  = var.location
  main_availability_zone = var.main_availability_zone
  state_path              = var.backend_bucket_name
  state_bucket_name       = var.bucket_path_prefix
  project_id              = var.project_id
  vpc_network_name        = module.gcp-tf-base.network_name
  vpc_network_subnet_name = module.gcp-tf-base.subnet_name
  replicas                = 1
}
*/
