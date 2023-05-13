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

/*
module "gcp-tf-vm" {

  source = "github.com/cloudymax/modules-gcp-tf-vm.git"

  project_id                  = var.project_id
  location                    = var.location
  main_availability_zone      = var.main_availability_zone
  big_robot_email             = var.big_robot_email
  machine_type                = var.machine_type
  guest_accelerator           = var.guest_accelerator
  guest_accelerator_count     = var.guest_accelerator_count
  provisioning_model          = "SPOT"
  instance_termination_action = "STOP"
  os_image                    = var.os_image
  disk_type                   = var.disk_type
  disk_size                   = var.disk_size
  userdata                    = var.userdata
}
*/


module "modules-gcp-gke" {

  source = "github.com/cloudymax/modules-gcp-gke.git"

  cluster_name            = var.cluster_name
  use_default_node_pool   = var.use_default_node_pool
  initial_node_count      = var.initial_node_count
  disk_type               = var.disk_type
  disk_size               = var.disk_size
  machine_type            = var.machine_type
  guest_accelerator       = var.guest_accelerator
  guest_accelerator_count = var.guest_accelerator_count
  autoscaling_enabled     = var.autoscaling_enabled
  autoscaling_min_nodes   = var.autoscaling_min_nodes
  autoscaling_max_nodes   = var.autoscaling_max_nodes
  autoscaling_strategy    = var.autoscaling_strategy
  node_service_account    = var.big_robot_email

  #autoscaling_max_mem     = var.autoscaling_max_mem
  #autoscaling_min_mem     = var.autoscaling_min_mem
  #autoscaling_min_cpu     = var.autoscaling_min_cpu
  #autoscaling_max_cpu     = var.autoscaling_max_cpu
  #container_name          = var.container_name
  #container_image         = var.container_image
  #replicas                = 1

  region                  = var.location
  main_availability_zone  = var.main_availability_zone
  state_path              = var.backend_bucket_name
  state_bucket_name       = var.bucket_path_prefix
  project_id              = var.project_id
  vpc_network_name        = module.gcp-tf-base.network_name
  vpc_network_subnet_name = module.gcp-tf-base.subnet_name
}


