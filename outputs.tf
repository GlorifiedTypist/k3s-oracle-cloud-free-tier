output "sqlpassword" {
  value = module.free-tier-k3s.sqlpassword
  sensitive = true
}

output "k3s-api-ip" {
  value = module.free-tier-k3s.k3s-api-ip
}

output "loadbalaner-ip" {
  value = "http://${module.free-tier-k3s.loadbalacer_ip}"
}
