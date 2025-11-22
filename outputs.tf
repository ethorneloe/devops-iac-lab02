output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg_static.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.sa_static.name
}

output "static_website_primary_endpoint" {
  description = "Primary web endpoint for the static website"
  value       = azurerm_storage_account.sa_static.primary_web_endpoint
}

output "static_website_url" {
  description = "URL to access the static website"
  value       = "https://${azurerm_storage_account.sa_static.primary_web_host}/"
}
