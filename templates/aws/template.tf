variable "bootstrap_expect" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "shared_security_group" {}
variable "key_name" {}
variable "web_image" {}
variable "ap_image" {}
variable "db_image" {}
variable "web_instance_type" {}
variable "ap_instance_type" {}
variable "db_instance_type" {}
variable "web_server_size" {}
variable "ap_server_size" {}
variable "db_server_size" {}

resource "aws_security_group" "web_security_group" {
  name = "WebSecurityGroup"
  description = "Enable SSH access, HTTP access via port 80"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ap_security_group" {
  name = "APSecurityGroup"
  description = "Enable AJP access via / JMX access"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 8009
    to_port = 8009
    protocol = "tcp"
    security_groups = ["${aws_security_group.web_security_group.id}"]
  }
  ingress {
    from_port = 12345
    to_port = 12346
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "db_security_group" {
  name = "DBSecurityGroup"
  description = "Enable DB access via port 5432"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${aws_security_group.ap_security_group.id}"]
  }
}

resource "aws_instance" "web_server" {
  count = "${var.web_server_size}"
  ami = "${var.web_image}"
  instance_type = "${var.web_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}", "${var.shared_security_group}"]
  subnet_id = "${element(split(", ", var.subnet_id), count.index)}"
  associate_public_ip_address = true
  tags {
    Name = "WebServer"
  }
}

resource "aws_instance" "ap_server" {
  count = "${var.ap_server_size}"
  depends_on = ["aws_instance.web_server"]
  ami = "${var.ap_image}"
  instance_type = "${var.ap_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ap_security_group.id}", "${var.shared_security_group.id}"]
  subnet_id = "${element(split(", ", var.subnet_id), count.index)}"
  associate_public_ip_address = true
  tags {
    Name = "APServer"
  }
}

resource "aws_instance" "db_server" {
  count = "${var.db_server_size}"
  depends_on = ["aws_instance.web_server"]
  ami = "${var.db_image}"
  instance_type = "${var.db_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.db_security_group.id}", "${var.shared_security_group.id}"]
  subnet_id = "${element(split(", ", var.subnet_id), count.index)}"
  associate_public_ip_address = true
  tags {
    Name = "DBServer"
  }
}

output "cluster_addresses" {
  value = "${join(", ", concat(aws_instance.web_server.*.private_ip, aws_instance.ap_server.*.private_ip, aws_instance.db_server.*.private_ip))}"
}

output "frontend_addresses" {
  value = "${join(", ", concat(aws_instance.web_server.*.public_ip, aws_instance.ap_server.*.public_ip, aws_instance.db_server.*.public_ip))}"
}
