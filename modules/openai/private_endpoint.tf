locals {
  private_dns_zone_exists = length(azurerm_private_dns_zone.dns_zone) > 0 || length(data.azurerm_private_dns_zone.dns_zone) > 0
  private_dns_zone_id     = local.private_dns_zone_exists ? (length(azurerm_private_dns_zone.dns_zone) > 0 ? azurerm_private_dns_zone.dns_zone[0].id : data.azurerm_private_dns_zone.dns_zone[0].id) : null
  private_dns_zone_name   = local.private_dns_zone_exists ? (length(azurerm_private_dns_zone.dns_zone) > 0 ? azurerm_private_dns_zone.dns_zone[0].name : data.azurerm_private_dns_zone.dns_zone[0].name) : null
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint

  location            = data.azurerm_resource_group.pe_vnet_rg[each.key].location
  name                = "${each.value.name}-${random_integer.suffix.result}"
  resource_group_name = data.azurerm_resource_group.pe_vnet_rg[each.key].name
  subnet_id           = data.azurerm_subnet.pe_subnet[each.key].id

  #tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
  #  avm_git_commit           = "89ebd082757e75b1568b79e009c1962ab9f15696"
  #  avm_git_file             = "private_endpoint.tf"
  #  avm_git_last_modified_at = "2023-06-07 14:06:42"
  #  avm_git_org              = "Azure"
  #  avm_git_repo             = "terraform-azurerm-openai"
  #  avm_yor_trace            = "3304cccb-6c7a-4b02-9ec7-ebaf6e185c07"
  #  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
  #  avm_yor_name = "this"
  #} /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))

  private_service_connection {
    is_manual_connection           = each.value.is_manual_connection
    name                           = "${each.value.private_service_connection_name}-${random_integer.suffix.result}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = var.pe_subresource
  }
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_entry_enabled ? ["private_dns_zone_group"] : []

    content {
      name                 = local.private_dns_zone_name
      private_dns_zone_ids = [local.private_dns_zone_id]
    }
  }
}

data "azurerm_private_dns_zone" "dns_zone" {
  count = length(var.private_endpoint) > 0 && var.private_dns_zone != null ? 1 : 0

  name                = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
}

resource "azurerm_private_dns_zone" "dns_zone" {
  count = length(var.private_endpoint) > 0 && var.private_dns_zone == null ? 1 : 0

  name                = "privatelink.openai.azure.com"
  resource_group_name = length(var.private_endpoint) > 0 && var.private_dns_zone != null ? "${var.private_dns_zone.resource_group_name}" : "${data.azurerm_resource_group.this.name}"
  tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "89ebd082757e75b1568b79e009c1962ab9f15696"
    avm_git_file             = "private_endpoint.tf"
    avm_git_last_modified_at = "2023-06-07 14:06:42"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-openai"
    avm_yor_trace            = "a33cc810-79db-4049-86dc-f451a95bc8b9"
    } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_yor_name = "dns_zone"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  for_each = var.private_endpoint

  name                  = "${each.value.dns_zone_virtual_network_link_name}-${random_integer.suffix.result}"
  private_dns_zone_name = local.private_dns_zone_name
  resource_group_name   = length(var.private_endpoint) > 0 && var.private_dns_zone != null ? var.private_dns_zone.resource_group_name : data.azurerm_resource_group.this.name
  virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id
  registration_enabled  = false
  tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "89ebd082757e75b1568b79e009c1962ab9f15696"
    avm_git_file             = "private_endpoint.tf"
    avm_git_last_modified_at = "2023-06-07 14:06:42"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-openai"
    avm_yor_trace            = "6df815d7-6c9c-498a-8494-550b9e8b8b5f"
    } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_yor_name = "dns_zone_link"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
  depends_on = [azurerm_private_endpoint.this]
}