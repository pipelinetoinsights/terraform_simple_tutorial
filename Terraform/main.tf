# Using a fixed prefix which we think is unique
variable "prefix" {
  default = "erftut"
}

# Set Azure region to Australia East
variable "location" {
  default = "australiaeast"
}

# ------------------------
# Step 1: Azure Environment Setup
# ------------------------

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg-data-pipeline"
  location = var.location
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "${var.prefix}-kv-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_storage_account" "adls" {
  name                     = "${var.prefix}adlsdatapipeline"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(["bronze", "silver", "gold"])
  name                  = "${var.prefix}-${each.value}"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "adf" {
  name                = "${var.prefix}-adf-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_storage_data_lake_gen2_filesystem" "adls_fs" {
  name               = "${var.prefix}-adls-fs"
  storage_account_id = azurerm_storage_account.adls.id

  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_databricks_workspace" "databricks" {
  name                = "${var.prefix}-databricks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
}

# Step 2: Data Ingestion
# You will need to manually configure the on-prem SQL Server and set up pipelines in ADF via UI or additional scripts.

# Step 3: Data Transformation
# Mount Data Lake in Databricks and transform data (this part is usually done in the Databricks notebooks).

# Step 4: Data Loading and Reporting
# Load data into Synapse and create Power BI Dashboard manually or via other scripts/tools.

# Step 5: Automation and Monitoring
# Schedule Pipelines and Monitor Pipeline Runs - typically done through ADF UI or via additional Terraform scripts.

# Step 6: Security and Governance

# Step 7: End-to-End Testing
# This involves manual testing by triggering pipelines and checking the results in the Power BI dashboard.