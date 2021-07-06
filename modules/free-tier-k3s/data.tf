data "oci_identity_availability_domains" "ad_list" {
  compartment_id = var.compartment_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ad_list.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad_list.availability_domains[count.index], "name")
}

data "template_file" "ad_worker_names" {
  count = length(var.freetier_worker_ad_list)
  template = lookup(data.oci_identity_availability_domains.ad_list.availability_domains[(var.freetier_worker_ad_list[count.index] -1)], "name")
}

data "oci_core_images" "images" {
  compartment_id = var.compartment_id
}

data "oci_identity_compartment" "default" {
  id = var.compartment_id
}

data "template_file" "externaldb_template" {
  template = file("${path.module}/scripts/externaldb.template.sh")

  vars = {
    password = random_password.sqlpassword.result
  }
}

data "template_file" "externaldb_cloud_init_file" {
  template = file("${path.module}/cloud-init/cloud-init.template.yaml")

  vars = {
    bootstrap_sh_content = base64gzip(data.template_file.externaldb_template.rendered)
  }

}

data "template_cloudinit_config" "externaldb" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "externaldb.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.externaldb_cloud_init_file.rendered
  }
}

data "template_file" "server_template" {
  template = file("${path.module}/scripts/server.template.sh")

  vars = {
    cluster_token = random_password.cluster_token.result
  }
}

data "template_file" "server_cloud_init_file" {
  template = file("${path.module}/cloud-init/cloud-init.template.yaml")

  vars = {
    bootstrap_sh_content = base64gzip(data.template_file.server_template.rendered)
  }

}

data "template_cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "server.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.server_cloud_init_file.rendered
  }
}

data "template_file" "worker_template" {
  template = file("${path.module}/scripts/worker.template.sh")

  vars = {
    cluster_token = random_password.cluster_token.result
  }
}

data "template_file" "worker_cloud_init_file" {
  template = file("${path.module}/cloud-init/cloud-init.template.yaml")

  vars = {
    bootstrap_sh_content = base64gzip(data.template_file.worker_template.rendered)
  }

}

data "template_cloudinit_config" "worker" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "worker.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.worker_cloud_init_file.rendered
  }
}

data "oci_core_images" "aarch64" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"

  filter {
    name   = "display_name"
    values = ["^.*-aarch64-.*$"]
    regex  = true
  }
}

data "oci_core_images" "amd64" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"

  filter {
    name   = "display_name"
    values = ["^([a-zA-z]+)-([a-zA-z]+)-([\\.0-9]+)-([\\.0-9-]+)$"]
    regex  = true
  }
}