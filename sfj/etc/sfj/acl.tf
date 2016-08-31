variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_name" {}
variable "network0" {}
variable "netmask0" {}

resource "aws_security_group" "allow_acl" {
  name = "allow_ssh_httpd"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

