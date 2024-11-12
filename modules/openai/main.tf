variable "prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "w2m"
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}
locals {
  account_name          = coalesce(var.account_name, "azure-openai-${random_integer.suffix.result}")
  custom_subdomain_name = coalesce(var.custom_subdomain_name, "azure-openai-${random_integer.suffix.result}")
  tags = merge(var.default_tags_enabled ? {
    Application_Name = var.application_name
    Environment      = var.environment
  } : {}, var.tags)
}
#---Cognitive Account
resource "azurerm_cognitive_account" "openai" {
  provider                      = azurerm
  name                          = "${var.cognitive_openai_name}-${random_integer.suffix.result}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  public_network_access_enabled = var.public_access
  custom_subdomain_name         = "${var.custom_subdomain_name}-${random_integer.suffix.result}" # Set your custom subdomain name here

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  dynamic "network_acls" {
    for_each = var.network_acls != null ? var.network_acls : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules != null ? network_acls.value.virtual_network_rules : []
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  for_each = var.deployment

  cognitive_account_id   = azurerm_cognitive_account.openai.id
  name                   = each.value.name
  rai_policy_name        = each.value.rai_policy_name
  version_upgrade_option = each.value.version_upgrade_option

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type     = each.value.scale_type
    capacity = try(each.value.capacity, 1)
  }
}

/*
#---Private Endpoint (Optional)
resource "azurerm_private_endpoint" "private_endpoint" {
  count               = var.use_private_endpoint == "true" ? 1 : 0
  name                = "${var.prefix}-pe-${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-peConn-${random_integer.suffix.result}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
    is_manual_connection           = "false"
  }
}

#---Monitoring
resource "azurerm_log_analytics_workspace" "AnaWorkspace" {
  count               = var.deployment_mode == "Production" ? 1 : 0
  name                = "${var.prefix}-AiMon-${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "monitor" {
  count                      = var.deployment_mode == "Production" ? 1 : 0
  name                       = "${var.prefix}-AiMon-${random_integer.suffix.result}"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.AnaWorkspace[0].id

  enabled_log {
    category = "AllLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "WorkspaceFree" {
  count               = var.deployment_mode == "PoC" ? 1 : 0
  name                = "${var.prefix}-AiMon-${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "monitorFree" {
  count                      = var.deployment_mode == "PoC" ? 1 : 0
  name                       = "${var.prefix}-AiMon-${random_integer.suffix.result}"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.WorkspaceFree[0].id

  enabled_log {
    category = "audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

*/