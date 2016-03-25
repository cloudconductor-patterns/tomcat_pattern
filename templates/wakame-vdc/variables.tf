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
variable "wakame_key_id" {
  description = "ID of an existing KeyPair on wakame-vdc to enable SSH access to the instances."
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
variable "web_cpu_cores" {
  description = "WebServer Cpu Cores"
  default = "1"
}
variable "web_memory_size" {
  description = "WebServer Memory Size"
  default = "512"
}
variable "ap_cpu_cores" {
  description = "APServer Cpu Cores"
  default = "1"
}
variable "ap_memory_size" {
  description = "APServer Memory Size"
  default = "512"
}
variable "db_cpu_cores" {
  description = "DBServer Cpu Cores"
  default = "1"
}
variable "db_memory_size" {
  description = "DBServer Memory Size"
  default = "512"
}
