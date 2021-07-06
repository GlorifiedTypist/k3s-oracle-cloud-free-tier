resource "oci_core_instance_configuration" "worker" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-worker"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_id
      display_name   = "worker"
      shape          = "VM.Standard.A1.Flex"

      create_vnic_details {
        subnet_id        = oci_core_subnet.public_subnet.id
        assign_public_ip = true
        hostname_label   = "worker"
      }

      shape_config {
        ocpus         = 2
        memory_in_gbs = 12
      }

      source_details {
        image_id    = data.oci_core_images.aarch64.images.0.id
        source_type = "image"
      }

      metadata = {
        ssh_authorized_keys = var.ssh_public_key
        user_data           = data.template_cloudinit_config.worker.rendered
      }
    }
  }

  lifecycle {
    ignore_changes = [
      instance_details[0].launch_details[0].source_details
    ]
  }
}

resource "oci_core_network_security_group" "nginx" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "nginx-loadbalancer"
}

resource "oci_core_network_security_group_security_rule" "nginx_http" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nginx.id
  protocol                  = "6"

  description = "Nginx Ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nginx_https" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nginx.id
  protocol                  = "6"

  description = "Nginx Ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_load_balancer" "nginx" {
  compartment_id             = var.compartment_id
  display_name               = "nginx-ingress"
  shape                      = "flexible"
  subnet_ids                 = [oci_core_subnet.public_subnet.id]
  network_security_group_ids = [oci_core_network_security_group.nginx.id]

  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
}

resource "oci_load_balancer_backend_set" "nginx" {
  load_balancer_id = oci_load_balancer.nginx.id
  name             = "nginx-ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 30080
    url_path          = "/healthz"
    return_code       = "200"
    retries           = 3
    interval_ms       = 10000
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_listener" "nginx" {
  default_backend_set_name = oci_load_balancer_backend_set.nginx.name
  load_balancer_id         = oci_load_balancer.nginx.id
  name                     = "nginx"
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "5"
  }
}

resource "oci_core_instance_pool" "worker" {
  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.worker.id
  size                      = 2
  display_name              = "${var.project_name}-worker"

  state = "RUNNING"

  dynamic "placement_configurations" {
    for_each = data.template_file.ad_worker_names[*].template
    content {
      availability_domain = placement_configurations.value
      primary_subnet_id   = oci_core_subnet.public_subnet.id
    }
  }

  load_balancers {
    backend_set_name = oci_load_balancer_backend_set.nginx.name
    load_balancer_id = oci_load_balancer.nginx.id
    port             = 30080
    vnic_selection   = "PrimaryVnic"
  }
}