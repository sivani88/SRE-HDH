terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74.0" # Assurez-vous que cette version correspond à celle que vous avez installée
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true # Évite la réinscription des providers après az login
}

# Variables configurables
variable "resource_group_name" {
  default = "rg-terraform-ssh"
}

variable "location" {
  default = "North Europe"
}

variable "vm_size" {
  default = "Standard_B1s"
}

# Groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Réseau minimal avec sous-réseau unique
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-terraform"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/25"]
}

# NSG avec ouverture uniquement du port 22 (SSH)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ssh"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Remplace "*" par ton IP si nécessaire
    destination_address_prefix = "*"
  }
}

# Association du NSG au sous-réseau
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Création des IP publiques pour les VMs
resource "azurerm_public_ip" "vm1_ip" {
  name                = "vm1-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "vm2_ip" {
  name                = "vm2-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Interface réseau VM1
resource "azurerm_network_interface" "vm1_nic" {
  name                = "nic-vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_ip.id
  }
}

# Interface réseau VM2
resource "azurerm_network_interface" "vm2_nic" {
  name                = "nic-vm2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2_ip.id
  }
}

# Machine virtuelle VM1 avec Debian 11 et SSH1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = "vm1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm1_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}

# Machine virtuelle VM2 avec Debian 11 et SSH2
resource "azurerm_linux_virtual_machine" "vm2" {
  name                  = "vm2"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}

# Output des IPs publiques des VMs
output "vm1_public_ip" {
  value = azurerm_public_ip.vm1_ip.ip_address
}

output "vm2_public_ip" {
  value = azurerm_public_ip.vm2_ip.ip_address
}
