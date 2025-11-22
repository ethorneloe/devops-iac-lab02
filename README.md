# Lab 02: Azure Static Website on Storage (with Remote Backend)

## Overview

This lab demonstrates how to deploy a static website using Azure Storage with static website hosting enabled. The Terraform state is stored remotely using the backend created in Lab 01 (Repo 1).

## Prerequisites

- Azure subscription and authenticated Azure CLI (`az login`)
- Terraform installed (>= 1.5.0)
- **Lab 01 (Remote Backend) must be completed first**
  - You need the resource group name and storage account name from Lab 01

## Architecture

This lab creates:
- Azure Resource Group for the static website resources
- Azure Storage Account (StorageV2) with static website hosting enabled
- Automatic upload of `index.html` and `error.html` to the `$web` container

## File Structure

```
02-azure-static-website-storage/
├── README.md                    # This file
├── main.tf                      # Resource definitions
├── providers.tf                 # Provider and backend configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore file
└── site/
    ├── index.html              # Website home page
    └── error.html              # 404 error page
```

## Lab Steps

### Step 1: Configure the Remote Backend

Before initializing Terraform, you need to update the backend configuration with values from Lab 01.

1. Get the backend values from Lab 01:
   ```bash
   cd ../01-azure-remote-backend  # Navigate to Lab 01
   terraform output
   ```

2. Note the following outputs:
   - `backend_resource_group_name`
   - `backend_storage_account_name`

3. Edit `providers.tf` in this directory and update the backend block:
   ```hcl
   backend "azurerm" {
     resource_group_name  = "your-backend-rg-name"      # From Lab 01 output
     storage_account_name = "your-backend-sa-name"      # From Lab 01 output
     container_name       = "tfstate"
     key                  = "static-website-${var.environment}.tfstate"
   }
   ```

### Step 2: Configure Variables

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and update with your values:
   ```hcl
   project_name   = "your-project-name"
   location       = "australiaeast"
   environment    = "dev"
   static_sa_name = "youruniquestaticsa123"  # Must be globally unique, lowercase, 3-24 chars
   ```

   **Important**: The `static_sa_name` must be:
   - Globally unique across all Azure storage accounts
   - 3-24 characters long
   - Lowercase letters and numbers only
   - No hyphens, underscores, or special characters

### Step 3: Initialize Terraform

Initialize Terraform to download providers and configure the remote backend:

```bash
terraform init
```

You should see a message confirming the backend has been initialized successfully.

### Step 4: Review the Execution Plan

Preview the resources that will be created:

```bash
terraform plan
```

Review the plan to ensure:
- Resource group will be created
- Storage account will be created with static website enabled
- Both HTML files will be uploaded

### Step 5: Apply the Configuration

Create the resources:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 6: Access Your Static Website

After the apply completes, Terraform will output the website URL:

```bash
terraform output static_website_url
```

Open the URL in your browser to view your static website!

You can also test the 404 error page by navigating to a non-existent page (e.g., `<your-url>/nonexistent.html`).

## Verification

1. **Check the website is live**:
   ```bash
   curl $(terraform output -raw static_website_primary_endpoint)
   ```

2. **Verify remote state**:
   - Navigate to the Azure Portal
   - Go to the backend storage account from Lab 01
   - Open the `tfstate` container
   - You should see `static-website-dev.tfstate` (or your environment name)

3. **Test the 404 page**:
   - Navigate to a non-existent page in your browser
   - You should see the custom error page

## Key Concepts

### Static Website Hosting

Azure Storage accounts with the StorageV2 kind support static website hosting:
- Content is served from a special `$web` container
- You can specify index and error documents
- Provides a public endpoint for your website
- Cost-effective solution for static content

### Remote Backend

This lab uses the remote backend from Lab 01:
- State is stored in Azure Storage (not locally)
- Enables team collaboration
- Provides state locking to prevent conflicts
- Supports state versioning and backup

### Storage Account Naming

Storage account names must follow strict rules:
- Globally unique across all of Azure
- 3-24 characters
- Lowercase letters and numbers only
- Used in the public URL: `https://<name>.z8.web.core.windows.net/`

## Outputs

| Output Name | Description |
|-------------|-------------|
| `resource_group_name` | Name of the resource group |
| `storage_account_name` | Name of the storage account |
| `static_website_primary_endpoint` | Primary web endpoint URL |
| `static_website_url` | Full HTTPS URL to access the website |

## Clean Up

To destroy the resources when you're done:

```bash
terraform destroy
```

**Note**: This will only destroy the static website resources. The remote backend from Lab 01 will remain intact.

## Troubleshooting

### Backend Initialization Issues

If you get an error during `terraform init`:
- Verify the backend resource group and storage account exist (from Lab 01)
- Ensure you have permissions to access the backend storage account
- Check that the `tfstate` container exists in the backend storage account

### Storage Account Name Conflict

If you get an error about the storage account name being taken:
- Storage account names must be globally unique
- Try a different name with a unique suffix
- Use only lowercase letters and numbers

### Website Not Loading

If the website URL doesn't work:
- Wait a few minutes for DNS propagation
- Check that both HTML files were uploaded to the `$web` container
- Verify the storage account has static website enabled

## Next Steps

- Update the HTML files in the `site/` directory and run `terraform apply` to update the website
- Add custom CSS, JavaScript, or additional pages
- Configure a custom domain for your static website
- Implement CI/CD to automatically deploy website changes

## Additional Resources

- [Azure Storage Static Websites](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
