data "aws_availability_zones" "all" {}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_launch_configuration" "terra1" {
  image_id           = "ami-07dc734dc14746eab"
  instance_type      = "t2.micro"
  security_groups    = ["${aws_security_group.terra1-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World! This is Terra1." > index.html
              nohup busybox httpd -f -p "{$var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "terra1-sg" {
  name = "terra1-sec-grp"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terra1-billing"
  }

  lifecycle {
    create_before_destroy = true
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

resource "aws_autoscaling_group" "terra1-asg" {
  launch_configuration = "${aws_launch_configuration.terra1.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 6

  tag {
    key                 = "Name"
    value               = "terraform-asg-terra1"
    propagate_at_launch = true
  }
}
