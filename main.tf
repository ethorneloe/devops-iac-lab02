locals {
  resource_group_name = var.static_rg_name != null ? var.static_rg_name : "${var.project_name}-${var.environment}-rg"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Resource Group for Static Website
resource "azurerm_resource_group" "rg_static" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Storage Account for Static Website
resource "azurerm_storage_account" "sa_static" {
  name                     = var.static_sa_name
  resource_group_name      = azurerm_resource_group.rg_static.name
  location                 = azurerm_resource_group.rg_static.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }

  tags = local.common_tags
}

# Upload index.html to $web container
resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.sa_static.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/site/index.html"
  content_type           = "text/html"
}

# Upload error.html to $web container
resource "azurerm_storage_blob" "error_html" {
  name                   = "error.html"
  storage_account_name   = azurerm_storage_account.sa_static.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/site/error.html"
  content_type           = "text/html"
}
