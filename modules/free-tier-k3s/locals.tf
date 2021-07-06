locals {
  server_ad_names = data.template_file.ad_names[*].rendered
}