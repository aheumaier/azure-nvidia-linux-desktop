provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you're using version 1.x, the "features" block is not allowed.
  version = "=1.40"
}

resource "random_string" "str" {
  length  = 16
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.naming-suffix}"
  location = var.location

  tags = {
    environment = "Terraform Nvidia Demo"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.naming-suffix}"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "Terraform Nvidia Demo"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.naming-suffix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.naming-suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform Nvidia Demo"
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.naming-suffix}"
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
    name                       = "VNC"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5900"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Terraform Nvidia Demo"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = "nic-${var.naming-suffix}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "config-${var.naming-suffix}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = {
    environment = "Terraform Nvidia Demo"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-${var.naming-suffix}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_NV6"
  os_profile {
    computer_name  = random_string.str.result # This is used as session x11vnc login
    admin_username = "azureuser"
    admin_password = random_string.str.result
    custom_data    = "${file("../scripts/setup_ubuntu_desktop.sh")}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_os_disk {
    name              = "osdisk-${var.naming-suffix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
   storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "Terraform Nvidia Demo"
  }
}

