output "sqlpassword" {
  value = random_password.sqlpassword.result
}

output "k3s-api-ip" {
  value = oci_core_instance.server.public_ip
}

output "ads" {
  value = data.oci_identity_availability_domains.ad_list
}

output "images_amd64" {
  value = data.oci_core_images.amd64.images.0
}

output "images_aarch64" {
  value = data.oci_core_images.aarch64.images.0
}

output "loadbalacer_ip" {
  value = oci_load_balancer.nginx.ip_addresses.0
}

output "local" {
  value = local.server_ad_names
}

output "ad_worker_names" {
  value = data.template_file.ad_worker_names[*].template
}