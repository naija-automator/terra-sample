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

  load_balancers       = ["${aws_elb.terra1_elb.name}"]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 6

  tag {
    key                 = "Name"
    value               = "terraform-asg-terra1"
    propagate_at_launch = true
  }
}

resource "aws_elb" "terra1_elb" {
  name         =   "terra1elb"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb-sg.id}"]

  listener {
    lb_port           =   80
    lb_protocol       =   "http"
    instance_port     =   "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold      =  2
    unhealthy_threshold    =  2
    timeout                =  3
    interval               =  30
    target                 =  "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb-sg" {
  name         =   "terra1-elb-sg"

  ingress {
    from_port    =   80
    to_port      =   80
    protocol     =   "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  
  egress {
    from_port    =   0
    to_port      =   0
    protocol     =   "-1"
    cidr_blocks  =   ["0.0.0.0/0"]
  }
}

output "elb_dns_name" {
  value  =  "${aws_elb.terra1_elb.dns_name}"
}
