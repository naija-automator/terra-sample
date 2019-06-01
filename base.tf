provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "base" {
  ami           = "ami-0009a33f033d8b7b6"
  instance_type = "t2.micro"

  tags {
    Name = "phunky-example"
  }
}

resource "aws_eip" "base" {
  instance = "${aws_instance.base.id}"
}
