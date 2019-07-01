provider "aws" {
	region = "us-east-1"
}

### EC2 instance
resource "aws_instance" "test_ec2" {
	ami = "ami-2d39803a"
	instance_type = "t2.micro"

	user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

	tags = {
		Name = "terraform-example"
	}

	vpc_security_group_ids = ["${aws_security_group.test_sec_group.id}"]
}

resource "aws_security_group" "test_sec_group" {
	name = "terraform-sg"

	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}