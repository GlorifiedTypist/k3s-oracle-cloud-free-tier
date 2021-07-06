resource "random_password" "sqlpassword" {
  length = 24
}

resource "oci_core_instance" "externaldb" {
  availability_domain = element(local.server_ad_names, (var.freetier_server_ad_list - 1))
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"

  display_name = "externaldb"

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    display_name     = "primary"
    assign_public_ip = false
    hostname_label   = "externaldb"
  }

  source_details {
    source_id   = data.oci_core_images.amd64.images.0.id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.externaldb.rendered
  }

  lifecycle {
    ignore_changes = [
      source_details
    ]
  }
}