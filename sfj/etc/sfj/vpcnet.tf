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

resource "aws_vpc" "main" {
  cidr_block = "${var.network0}/${var.netmask0}"
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.network0}/${var.netmask0}"
}

resource "aws_internet_gateway" "sfj_igw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "sfj_igw_route" {
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.sfj_igw.id}"
}

resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.main.id}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
}

