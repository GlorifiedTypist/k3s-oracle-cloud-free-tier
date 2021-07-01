module "free-tier-k3s" {
  source = "./modules/free-tier-k3s"

  # General
  project_name   = "ftk3s"
  region         = var.region
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaxxxxxxxxxxxxxxxyyyy"
  ssh_public_key = file("~/.ssh/id_rsa.pub")

  # Network
  whitelist_subnets = [
    "172.217.170.4/32",
    "10.0.0.0/8"
  ]

  vcn_subnet     = "10.0.0.0/16"
  private_subnet = "10.0.2.0/23"
  public_subnet  = "10.0.0.0/23"

  freetier_ad_list = [
    "gsEM:UK-LONDON-1-AD-3"
  ]
}
