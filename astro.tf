# Data source for existing subnet
data "azurerm_subnet" "transit_east_subnet" {
  name                 = "azure-transit-us-east-Public-gateway-and-firewall-mgmt-1"
  virtual_network_name = "azure-transit-us-east"
  resource_group_name  = "rg-av-azure-transit-us-east-247007"
}

# Network Security Group for Astro subnet
resource "azurerm_network_security_group" "astro_nsg" {
  name                = "nsg-astro-control-plane"
  location            = var.location
  resource_group_name = data.azurerm_subnet.transit_east_subnet.resource_group_name

  tags = merge(local.common_tags, {
    Purpose = "Astro Control Plane Security"
  })
}

resource "azurerm_network_security_rule" "allow_astro_dev_internet" {
  name                        = "Allow-Astro-API"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "10.130.32.0/20"
  destination_address_prefix  = "Internet"
  resource_group_name         = "rg-av-azure-transit-us-east-247007"
  network_security_group_name = azurerm_network_security_group.astro_nsg.name
}

# Allow Astro Install endpoint
resource "azurerm_network_security_rule" "allow_astro_dev_internal" {
  for_each                     = var.astro_internal_targets
  name                         = "Allow-Astro-${each.key}"
  priority                     = 110 + each.value.priority
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = each.value.target_port
  source_address_prefix        = "10.130.32.0/20"
  destination_address_prefixes = each.value.target_addresses
  resource_group_name          = "rg-av-azure-transit-us-east-247007"
  network_security_group_name  = azurerm_network_security_group.astro_nsg.name
  description                  = "Allow astro cluster to ${each.key}"
}

# Deny all other outbound traffic from Astro CIDR
resource "azurerm_network_security_rule" "deny_astro_dev_outbound" {
  name                        = "Deny-Astro-CIDR-Outbound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.130.32.0/20"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-av-azure-transit-us-east-247007"
  network_security_group_name = azurerm_network_security_group.astro_nsg.name
  description                 = "Block all other outbound from Astro CIDR"
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "astro_dev_nsg_association" {
  subnet_id                 = data.azurerm_subnet.transit_east_subnet.id
  network_security_group_id = azurerm_network_security_group.astro_nsg.id
}

resource "azurerm_network_security_rule" "allow_remainder_inbound" {
  name                        = "Allow-Existing-Inbound"
  priority                    = 4011
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*" # Adjusted from "4" assuming you meant all traffic
  destination_address_prefix  = "rg-av-azure-transit-us-east-247007" 
  network_security_group_name = azurerm_network_security_group.astro_nsg.name
  resource_group_name         = "rg-av-azure-transit-us-east-247007" # NSG rules usually require the RG name
  description                 = "Allow all other existing traffic"
}
