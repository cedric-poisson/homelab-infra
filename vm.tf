resource "azurerm_public_ip" "vm_test" {
  name                = "pip-vm-test-01"
  resource_group_name = azurerm_resource_group.homelab.name
  location            = azurerm_resource_group.homelab.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "vm_test" {
  name                = "nsg-vm-test-01"
  resource_group_name = azurerm_resource_group.homelab.name
  location            = azurerm_resource_group.homelab.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_test" {
  name                = "nic-vm-test-01"
  resource_group_name = azurerm_resource_group.homelab.name
  location            = azurerm_resource_group.homelab.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_test.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm_test" {
  network_interface_id     = azurerm_network_interface.vm_test.id
  network_security_group_id = azurerm_network_security_group.vm_test.id
}

resource "azurerm_linux_virtual_machine" "vm_test" {
  name                = "vm-test-01"
  resource_group_name = azurerm_resource_group.homelab.name
  location            = azurerm_resource_group.homelab.location
  size                = "Standard_B2ats_v2"
  admin_username      = "cedric"

  network_interface_ids = [
    azurerm_network_interface.vm_test.id,
  ]

  admin_ssh_key {
    username   = "cedric"
    public_key = file("~/.ssh/homelab_vm_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}