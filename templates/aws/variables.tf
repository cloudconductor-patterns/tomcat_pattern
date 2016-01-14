variable "vpc_id" {
  description = "VPC ID which is created by common network pattern."
}
variable "subnet_ids" {
  description = "Subnet ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "key_name" {
  description = "Name of an existing EC2/OpenStack KeyPair to enable SSH access to the instances."
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
variable "web_instance_type" {
  description = "WebServer instance type"
  default = "t2.small"
}
variable "ap_instance_type" {
  description = "WebServer instance type"
  default = "t2.small"
}
variable "db_instance_type" {
  description = "WebServer instance type"
  default = "t2.small"
}
variable "web_server_size" {
  description = "WebServer instance size"
  default = "1"
}
variable "ap_server_size" {
  description = "APServer instance size"
  default = "1"
}
variable "db_server_size" {
  description = "DBServer instance size"
  default = "1"
}
