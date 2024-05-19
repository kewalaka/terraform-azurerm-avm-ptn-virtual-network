module "subnets" {
  for_each = var.subnets

  # TODO revert to Azure org pending fix: https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork/pull/74
  source = "git::https://github.com/kewalaka/terraform-azurerm-avm-res-network-virtualnetwork?ref=dev"
  # source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  # version = "0.2.0"

  existing_vnet = {
    resource_id = var.virtual_network_resource_id
  }
  location            = var.location
  resource_group_name = var.resource_group_name
  subnets             = local.subnets

  depends_on = [module.network_security_groups]
}


module "network_security_groups" {
  for_each = var.network_security_groups

  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  resource_group_name = var.resource_group_name
  name                = each.value.name
  security_rules      = try(each.value.security_rules, {})
  location            = var.location
}

# replace with an AVM when available
resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = each.value.tags

  dynamic "route" {
    for_each = try(each.value.routes, {})
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }
}
