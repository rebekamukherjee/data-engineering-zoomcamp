variable "credentials" {
  description = "My Credentials"
  default     = "./keys/creds.json"
}

variable "project" {
  description = "Project"
  default     = "fleet-furnace-412302"
}

variable "region" {
  description = "Region"
  default     = "us-west3"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "fleet-furnace-412302-terra-bucket" # must be unique
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}