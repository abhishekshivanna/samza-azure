data "template_file" "yarn_config" {
  template = "${file("${path.module}/conf/yarn-site.xml")}"

  vars = {
    resource_manager_ip = "${var.resource_manager_ip_address}"
  }
}

//resource "local_file" "yarn_config" {
//  filename = "${local.yarn_config_path}"
//  content  = "${data.template_file.yarn_config.rendered}"
//}