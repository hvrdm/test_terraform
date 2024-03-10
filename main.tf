provider "azurerm" {
features{}
}

resource "azurerm_resource_group" "HashiGroup" {
name    = "HashiGroup"
location = "West Europe"
}

resource "azurerm_public_ip" "VM1pubip" {
name                 = "VM1PubIP"
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name
allocation_method    = "Dynamic"
}

resource "azurerm_public_ip" "VM2pubip" {
name                 = "VM2PubIP"
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name
allocation_method    = "Dynamic"
}

resource "azurerm_virtual_network" "HashiNet" {
name                 = "vnet1"
address_space        = ["10.1.0.0/16"]
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name
}

resource "azurerm_subnet" "HashiSub" {
name                 = "default"
resource_group_name  = azurerm_resource_group.HashiGroup.name
virtual_network_name = azurerm_virtual_network.HashiNet.name
address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "RDPNSG" {
name                 = "RemoteDesktopSecurityGroup"
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name
}

resource "azurerm_network_security_rule" "RDPrule" {
name                         = "rdpin"
priority                     = 100
direction                    = "Inbound"
access                       = "Allow"
protocol                     = "*"
source_port_range            = "*"
destination_port_range       = "3389"
source_address_prefix        = "*"
destination_address_prefix   = "*"
resource_group_name          = azurerm_resource_group.HashiGroup.name
network_security_group_name  = azurerm_network_security_group.RDPNSG.name
}

resource "azurerm_network_interface" "vm1NIC" {
name                 = "vm1NIC"
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name

  ip_configuration {
    name                          = "intern"
    subnet_id                     = azurerm_subnet.HashiSub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VM1pubip.id
    }   
}

resource "azurerm_network_interface" "vm2NIC" {
name                 = "vm2NIC"
location             = azurerm_resource_group.HashiGroup.location
resource_group_name  = azurerm_resource_group.HashiGroup.name

  ip_configuration {
    name                          = "intern"
    subnet_id                     = azurerm_subnet.HashiSub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VM2pubip.id
    }
}

resource "azurerm_network_interface_security_group_association" "NSGAssocVM1" {
  network_interface_id      = azurerm_network_interface.vm1NIC.id
  network_security_group_id = azurerm_network_security_group.RDPNSG.id
}

resource "azurerm_network_interface_security_group_association" "NSGAssocVM2" {
  network_interface_id      = azurerm_network_interface.vm2NIC.id
  network_security_group_id = azurerm_network_security_group.RDPNSG.id
}



resource "azurerm_windows_virtual_machine" "WindowsVM1" {
name                 = "vm1"
resource_group_name  = azurerm_resource_group.HashiGroup.name
location             = azurerm_resource_group.HashiGroup.location
size                 = "Standard_F2"
admin_username       = "adminuser"
admin_password       = "Student123"
network_interface_ids = [
  azurerm_network_interface.vm1NIC.id,
]


os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
    }
}    
resource "azurerm_windows_virtual_machine" "WindowsVM2" {
name                 = "vm2"
resource_group_name  = azurerm_resource_group.HashiGroup.name
location             = azurerm_resource_group.HashiGroup.location
size                 = "Standard_F2"
admin_username       = "adminuser"
admin_password       = "Student123"
network_interface_ids = [
  azurerm_network_interface.vm2NIC.id,
]


os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}


source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
    }
}



    

