resource "aws_eip" "eipSFJPARA" {
  depends_on = ["aws_internet_gateway.SFJTAGS_igw"]
  instance = "${aws_instance.hostSFJPARA.id}"
  vpc = true
  provisioner "remote-exec" {
    inline = [
      "sleep 10"
    ]
    connection {
      host = "${self.public_ip}"
      user = "${var.ansible_ssh_user}"
      private_key = "${var.privatekeyfile}"
      timeout = "${var.tftimeout}"
    }
  }
}

