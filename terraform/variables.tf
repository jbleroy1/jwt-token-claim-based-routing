variable "regions" {
  description = "Region where a GKE cluster has to be created"
  type        = list(string)
  default     = ["europe-west2"]
}

variable "project_id" {
  description = "Project id"
  type        = string
}

variable "project_number" {
  description = "Project number"
  type        = string
}