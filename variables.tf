variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "australiaeast"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "static_rg_name" {
  description = "Name of the resource group for static website (optional, defaults to project_name-environment-rg)"
  type        = string
  default     = null
}

variable "static_sa_name" {
  description = "Name of the storage account for static website (must be lowercase letters and numbers only, 3-24 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.static_sa_name))
    error_message = "Storage account name must be lowercase letters and numbers only, between 3 and 24 characters."
  }
}
