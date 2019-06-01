provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "terra1" {
  ami           = "ami-07dc734dc14746eab"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.terra1-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World! This is Terra1." > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags {
    Name = "terra_vms"
  }
}

resource "aws_eip" "terra1_eip" {
  instance = "${aws_instance.terra1.id}"
}

resource "aws_security_group" "terra1-sg" {
  name   = "terra1-sec-grp"

  ingress {
    from_port  =  8080
    to_port    =  8080
    protocol   =  "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terra1-billing"
  }
}

output "public_ip" {
  value = "${aws_instance.terra1.public_ip}"
}
