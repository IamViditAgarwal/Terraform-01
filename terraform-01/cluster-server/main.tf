resource "aws_launch_configuration" "test_lc" {
  image_id        = "ami-0f5076fff7c490719"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_sg.id}"]



  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "test_sg" {
  name = "terraform-sg"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "test_asg" {
  launch_configuration = "${aws_launch_configuration.test_lc.id}"
  availability_zones   = "${data.aws_availability_zones.all.names}"

  load_balancers    = ["${aws_elb.test_elb.name}"]
  health_check_type = "ELB"

  min_size = 1
  max_size = 2

  tag {
    key                 = "Name"
    value               = "terraform-instance"
    propagate_at_launch = true
  }
}

resource "aws_elb" "test_elb" {
  name               = "terraform-elb"
  availability_zones = "${data.aws_availability_zones.all.names}"
  security_groups    = ["${aws_security_group.test_sg_elb.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }
}

resource "aws_security_group" "test_sg_elb" {
  name = "terraform-sec-group-elb"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}