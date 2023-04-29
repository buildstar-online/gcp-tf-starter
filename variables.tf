variable "project_name" {
  description = "The human-readbale project name string"
  type        = string
}

variable "project_id" {
  description = "machine readable project name"
  type        = string
}

variable "big_robot_name" {
  description = "Name of the top-level service account"
  type        = string
}

variable "big_robot_group" {
  description = "group for top-level service accounts"
  type        = string
}

variable "big_robot_email" {
  description = "email of the top-level service account"
  type        = string
}

variable "organization" {
  description = "your GCP organization name"
  type        = string
}

variable "organization_id" {
  description = "gcloud projects describe <project> --format='value(parent.id)'"
  type        = string
}

variable "location" {
  description = "geographic location/region"
  type        = string
}

variable "main_availability_zone" {
  description = "availability zone within your region/location"
  type        = string
}

variable "keyring" {
  description = "Name for your keyring decryption key"
  type        = string
}

variable "keyring_key" {
  description = "name for the key you will create in the keyring"
  type        = string
}

variable "billing_account" {
  description = "the billing account you want all this to go under"
  type        = string
}

variable "backend_bucket_name" {
  description = "name of the bucket that will hold the terraform state"
  type        = string
  default     = "slim"
}

variable "bucket_path_prefix" {
  description = "path to the terrafom state in the bucket"
  type        = string
}

variable "machine_type" {
  description = "The GCP machine type to use for the VM or Nodes"
  type        = string
}

variable "guest_accelerator" {
  description = "GPU or TPU to attach to the virtual-machine."
  type        = string
}

variable "guest_accelerator_count" {
  description = "Number of accelerators to attach to each machine"
  type        = number
}

variable "os_image" {
  type        = string
  description = "Operating system to use on VM's and nodes"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "userdata" {
  type        = string
  description = "Cloud-init user-data.yaml file to apply to each VM or Node"
  default     = "user-data.yaml"
}

variable "disk_size" {
  type        = number
  description = "default size of the OS Disk for each VM or Node"
  default     = 64
}

variable "use_default_node_pool" {
  description = "True=use the deafult GKE node pool, Fale=use seprately managed pool"
  type        = bool
  default     = false
}

variable "initial_node_count" {
  description = "Number of nodes the GKE cluster starts with"
  type        = number
  default     = 1
}

variable "cluster_name" {
  description = "Name of the GKE cluster we will create"
  type        = string
  default     = "my-cluster"
}

variable "autoscaling_enabled" {
  description = "set autoscaling true or false"
  type        = bool
  default     = true
}

variable "autoscaling_min_nodes" {
  description = "min number of nodes allocation"
  type        = number
  default     = 1
}

variable "autoscaling_max_nodes" {
  description = "max number of nodes allowed"
  type        = number
  default     = 1
}

/*
variable "autoscaling_min_cpu" {
  description = "min cpu allocation"
  type        = number
  default     = 1
}

variable "autoscaling_max_cpu" {
  description = "max cpu allowed"
  type        = number
  deafult     = 2
}

variable "autoscaling_min_mem" {
  description = "min memory allocation"
  type        = number
  default     = 
}

variable "autoscaling_max_mem" {
  description = "max memory allocation"
  type        = number
}
*/

variable "autoscaling_strategy" {
  description = "GKE autoscaling strategy. BALANCED or ANY"
  type        = string
  default     = "ANY"
}

/*
variable "container_image" {
  description = "docker or container repo image url "
  type        = string
}

variable "container_name" {
  description = "name of the container"
  type        = string
}

variable "replicas" {
  description = "number of replicas"
  type        = number
}
*/

variable "disk_type" {
  description = " 'pd-standard', 'pd-balanced' or 'pd-ssd' "
  type        = string
}

