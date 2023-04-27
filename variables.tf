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
