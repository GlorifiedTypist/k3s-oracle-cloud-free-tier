resource "random_password" "cluster_token" {
  length = 64
}


resource "oci_core_instance" "server" {
  availability_domain = element(local.server_ad_names, (var.freetier_server_ad_list - 1))
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"

  display_name = "server"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "primary"
    assign_public_ip = true
    hostname_label   = "server"
  }

  agent_config {
    plugins_config {
      name          = "OS Management Service Agent"
      desired_state = "DISABLED"
    }
  }

  source_details {
    source_id   = data.oci_core_images.amd64.images.0.id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.server.rendered
  }

  lifecycle {
    ignore_changes = [
      source_details
    ]
  }
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = "until $(curl --connect-timeout 3 -k -s --head --fail https://${oci_core_instance.server.public_ip}:6443; if [ \"$?\" == \"22\" ]; then echo true; else echo false; fi); do sleep 5; done; sleep 15; scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null opc@${oci_core_instance.server.public_ip}:/home/opc/.kube/config ~/.kube/k3s"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    oci_core_instance.server
  ]
}
