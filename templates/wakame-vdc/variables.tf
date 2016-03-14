variable "global_network" {
  description = "Global Network ID to reach internet on Wakame-vdc"
  default = "nw-global"
}
variable "subnet_ids" {
  description = "Network ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "key_name" {
  description = "Name of an existing KeyPair to enable SSH access to the instances."
}
variable "web_image" {
  description = "[computed] WebServer Image Id. This parameter is automatically filled by CloudConductor."
}
variable "ap_image" {
  description = "[computed] APServer Image Id. This parameter is automatically filled by CloudConductor."
}
variable "db_image" {
  description = "[computed] DBServer Image Id. This parameter is automatically filled by CloudConductor."
}
