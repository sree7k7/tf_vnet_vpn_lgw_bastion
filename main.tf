## This template creates on Vnet and two subnets (public and private) and vm
# Generate Random resource_group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "vnet_work" {
  name                = var.vnet_config["vnetname"]
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create public subnet
resource "azurerm_subnet" "vnet_public_subnet" {
  name                 = var.vnet_config["public_subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = var.public_subnet_address
}

# Create private subnet
resource "azurerm_subnet" "vnet_private_subnet" {
  name                 = var.vnet_config["private_subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = var.private_subnet_address
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "SecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "InternetAccess"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "PublicIp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method   = "Dynamic"
}
# Create network interface
resource "azurerm_network_interface" "public_nic" {
  name                = "NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_config"
    subnet_id                     = azurerm_subnet.vnet_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface (NIC)
resource "azurerm_network_interface_security_group_association" "connect_nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.public_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.resource_group_location}-Vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.public_nic.id]
  size                  = "Standard_DS1_v2"
  admin_username                  = "demousr"
  admin_password                  = "Password@123"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server; powershell -ExecutionPolicy Unrestricted Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.html\" -Value $($env:computername)"
    }
SETTINGS
}


##create azure GatewaySubnet
resource "azurerm_subnet" "vnet_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = var.gateway_subnet_address
}
resource "azurerm_public_ip" "GatewaySubnetPublicIp" {
  name                = "GatewaySubnetPublicIp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method   = "Dynamic"
}

##create azure virtual network gateway 
resource "azurerm_virtual_network_gateway" "VirtualNetworkGateway" {
  name                = "VirtualNetworkGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "VPN"
  vpn_type            = "RouteBased"
  sku                 = "Standard"
  enable_bgp          = true
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.GatewaySubnetPublicIp.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_gateway_subnet.id
  }
  bgp_settings {
    asn                           = 65020
  }
}

# Local network Gateway
resource "azurerm_local_network_gateway" "onpremise" {
  name                = "onpremise-details"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.vpn_gateway_pip
  bgp_settings {
      asn                 = var.asn
      bgp_peering_address = var.bgp_peering_address
      peer_weight         = 0
    }
  depends_on = [
    azurerm_virtual_network_gateway.VirtualNetworkGateway
  ]
}

# Site to site VPN
resource "azurerm_virtual_network_gateway_connection" "vng_connection_to_lgw-onpremise" {
  name                = "vng_connection_to_lgw-onpremise"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VirtualNetworkGateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id
  shared_key = "abc@143"
  enable_bgp = true
}

# Azure Bastion host
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = var.bastion_subnet_address
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion_pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionHost" {
  name                = "BastionHost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion_pip_config"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
