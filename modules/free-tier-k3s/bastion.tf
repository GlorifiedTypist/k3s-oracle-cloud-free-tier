resource "oci_bastion_bastion" "main" {
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_id
  target_subnet_id = oci_core_subnet.private_subnet.id

  name                         = var.project_name
  client_cidr_block_allow_list = var.whitelist_subnets
}