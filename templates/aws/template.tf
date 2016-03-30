resource "aws_eip" "web_server_eip" {
  vpc = true
  instance = "${aws_instance.web_server.id}"
}

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
  ami = "${var.web_image}"
  instance_type = "${var.web_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}", "${var.shared_security_group}"]
  subnet_id = "${element(split(", ", var.subnet_ids), 0)}"
  associate_public_ip_address = true
  tags {
    Name = "WebServer"
  }
}

resource "aws_instance" "ap_server" {
  depends_on = ["aws_instance.web_server"]
  ami = "${var.ap_image}"
  instance_type = "${var.ap_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ap_security_group.id}", "${var.shared_security_group.id}"]
  subnet_id = "${element(split(", ", var.subnet_ids), 0)}"
  associate_public_ip_address = true
  tags {
    Name = "APServer"
  }
}

resource "aws_instance" "db_server" {
  depends_on = ["aws_instance.web_server"]
  ami = "${var.db_image}"
  instance_type = "${var.db_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.db_security_group.id}", "${var.shared_security_group.id}"]
  subnet_id = "${element(split(", ", var.subnet_ids), 0)}"
  associate_public_ip_address = true
  tags {
    Name = "DBServer"
  }
}

output "cluster_addresses" {
  value = "${aws_instance.web_server.private_ip}, ${aws_instance.ap_server.private_ip}, ${aws_instance.db_server.private_ip}"
}

output "consul_addresses" {
  value = "${aws_eip.web_server_eip.public_ip}, ${aws_instance.ap_server.public_ip}, ${aws_instance.db_server.public_ip}"
}

output "frontend_address" {
  value = "${aws_eip.web_server_eip.public_ip}"
}
