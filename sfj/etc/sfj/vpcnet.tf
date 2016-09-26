variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "reagion" {}
variable "private_key_name" {}
variable "network0" {}
variable "netmask0" {}

provider "aws" {
  access_key= "${var.aws_access_key}"
  secret_key= "${var.aws_secret_key}"
  region = "${var.reagion}"
}

resource "aws_vpc" "SFJTAGS_vpc" {
  cidr_block = "${var.network0}/${var.netmask0}"
  tags {
    Name = "SFJTAGS_vpc"
  }
}

resource "aws_subnet" "SFJTAGS_subnet" {
  vpc_id = "${aws_vpc.SFJTAGS_vpc.id}"
  cidr_block = "${var.network0}/${var.netmask0}"
  tags {
    Name = "SFJTAGS_subnet"
  }
}

resource "aws_internet_gateway" "SFJTAGS_igw" {
  vpc_id = "${aws_vpc.SFJTAGS_vpc.id}"
  tags {
    Name = "SFJTAGS"
  }
}

resource "aws_route" "SFJTAGS_igw_route" {
  route_table_id = "${aws_vpc.SFJTAGS_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.SFJTAGS_igw.id}"
}

resource "aws_route_table_association" "SFJTAGS_route_table" {
  subnet_id = "${aws_subnet.SFJTAGS_subnet.id}"
  route_table_id = "${aws_vpc.SFJTAGS_vpc.main_route_table_id}"
}

