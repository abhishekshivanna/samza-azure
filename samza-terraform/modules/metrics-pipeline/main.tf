locals {
  virtual_machine_name = "${var.prefix}-${var.metrics-prefix}-vm"
}

resource "azurerm_public_ip" "metrics_public_ip" {
  name                = "${var.prefix}-${var.metrics-prefix}-publicip"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = var.location
  allocation_method   = "Static" # TODO: Use Dynamic (Blocker: for some reason remote-exec fails to pick up IP with set to Dynamic)
}

resource "azurerm_network_interface" "metrics_nic" {
  name                      = "${var.prefix}-${var.metrics-prefix}-nic"
  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.resource_group.name
  network_security_group_id = data.azurerm_network_security_group.metrics_nsg.id

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.azurerm_subnet.metrics_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.metrics_public_ip.id # TODO: Figure out a way not to use public IPs
  }
}

resource "azurerm_virtual_machine" "metrics_instance" {
  name                  = local.virtual_machine_name
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.metrics_nic.id]
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
    name              = "${var.prefix}-${var.metrics-prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.virtual_machine_name
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
      host     = azurerm_public_ip.metrics_public_ip.ip_address
    }

    source      = "${path.module}/bin/metrics-pipeline.sh"
    destination = "metrics-pipeline.sh"
  }

  provisioner "file" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host     = azurerm_public_ip.metrics_public_ip.ip_address
    }

    source      = "${path.module}/conf/prometheus.yml"
    destination = "prometheus.yml"
  }

  provisioner "file" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host     = azurerm_public_ip.metrics_public_ip.ip_address
    }

    content     = data.template_file.kafka_server_config.rendered
    destination = "kafka-server.conf"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh" # TF-UPGRADE-TODO: If this is a windows instance without an SSH server, change to "winrm"
      user     = var.username
      password = var.password
      host     = azurerm_public_ip.metrics_public_ip.ip_address
    }

    inline = [
      "wget https://dl.grafana.com/oss/release/grafana-6.5.0-1.x86_64.rpm",
      "echo ${var.password} | sudo -S yum install -y java-1.8.0-openjdk-headless",
      "sudo yum install -y nc",
      "sudo yum localinstall -y grafana-6.5.0-1.x86_64.rpm",
      "sudo service grafana-server start",
      "chmod +x metrics-pipeline.sh",
      "bash metrics-pipeline.sh download",
      "bash metrics-pipeline.sh start",
    ]
  }
}
