locals {
  virtual_machine_name = "${var.prefix}-${var.nm-prefix}-vm"
}

resource "azurerm_public_ip" "node_manager_public_ip" {
  count               = var.nm_count
  name                = "${var.prefix}-${var.nm-prefix}-publicip-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  allocation_method   = "Static" # TODO: Use Dynamic (Blocker: for some reason remote-exec fails to pick up IP with set to Dynamic)
}

resource "azurerm_network_interface" "node_manager_nic" {
  count                     = var.nm_count
  name                      = "${var.prefix}-${var.nm-prefix}-nic-${count.index}"
  location                  = data.azurerm_resource_group.resource_group.location
  resource_group_name       = data.azurerm_resource_group.resource_group.name
  network_security_group_id = data.azurerm_network_security_group.node_manager_nsg.id

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.azurerm_subnet.node_manager_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.node_manager_public_ip.*.id, count.index) # TODO: Figure out a way not to use public IPs
  }
}

resource "azurerm_virtual_machine" "node_manager_instance" {
  count                 = var.nm_count
  name                  = "${local.virtual_machine_name}-${count.index}"
  location              = data.azurerm_resource_group.resource_group.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  network_interface_ids = [element(azurerm_network_interface.node_manager_nic.*.id, count.index)]
  vm_size               = var.vm_size # TODO: Replace this with a var

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.storage_image_publisher
    offer     = var.storage_image_offer
    sku       = var.storage_image_sku
    version   = var.storage_image_version
  }

  storage_os_disk {
    name              = "${var.prefix}-${var.nm-prefix}-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}-${count.index}"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "file" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host = element(
        azurerm_public_ip.node_manager_public_ip.*.ip_address,
        count.index,
      )
    }

    source      = "${path.module}/bin/nm.sh"
    destination = "nm.sh"
  }

  provisioner "file" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host = element(
        azurerm_public_ip.node_manager_public_ip.*.ip_address,
        count.index,
      )
    }

    content     = data.template_file.yarn_config.rendered
    destination = "yarn-site.xml"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host = element(
        azurerm_public_ip.node_manager_public_ip.*.ip_address,
        count.index,
      )
    }

    inline = [
      "echo ${var.password} | sudo -S yum install -y java-1.8.0-openjdk-headless",
      "sudo yum install -y nc",
      "chmod +x nm.sh",
      "bash nm.sh start",
    ]
  }
}
