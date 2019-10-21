locals {
  virtual_machine_name = "${var.prefix}-${var.rm-prefix}-vm"
}

resource "azurerm_public_ip" "node_manager_public_ip" {
  name                = "${var.prefix}-${var.rm-prefix}-publicip"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  allocation_method   = "Static" # TODO: Use Dynamic (Blocker: for some reason remote-exec fails to pick up IP with set to Dynamic)
}

resource "azurerm_network_interface" "node_manager_nic" {
  name                = "${var.prefix}-${var.rm-prefix}-nic"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  network_security_group_id = "${data.azurerm_network_security_group.node_manager_nsg.id}"

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = "${data.azurerm_subnet.node_manager_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.node_manager_public_ip.id}" # TODO: Figure out a way not to use public IPs
  }
}

resource "azurerm_virtual_machine" "node_manager_instance" {
  name                  = "${local.virtual_machine_name}"
  location              = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.node_manager_nic.id}"]
  vm_size               = "Baisc_A1" # TODO: Replace this with a var

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-${var.rm-prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "file" {
    connection {
      user     = "${var.username}"
      password = "${var.password}"
      host = "${azurerm_public_ip.node_manager_public_ip.ip_address}"
    }

    source      = "bin/nm.sh"
    destination = "/etc/nm.sh"
  }

  provisioner "file" {
    connection {
      user     = "${var.username}"
      password = "${var.password}"
      host = "${azurerm_public_ip.node_manager_public_ip.ip_address}"
    }

    content = "${data.template_file.yarn_config}"
    destination = "/etc/yarn-site.xml"
  }

  provisioner "remote-exec" {
    connection {
      user     = "${var.username}"
      password = "${var.password}"
      host = "${azurerm_public_ip.node_manager_public_ip.ip_address}"
    }

    inline = [
      "chmod +x /etc/nm.sh",
      "/etc/nm.sh start"
    ]
  }
}