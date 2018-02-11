# Create a security group that will allow us to both
# SSH into the instance as well as access prometheus
# publicly (note.: you'd not do this in prod - otherwise
# you'd have prometheus publicly exposed).
resource "aws_security_group" "instance" {
  name = "main"

  description = "Allows SSH traffic into instances as well as all eggress."
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh-all"
  }
}

# Create an EC2 instance that will interact with an EFS
# filesystem that is mounted in out specific availability
# zone.
resource "aws_instance" "main" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance-type}"
  key_name               = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  availability_zone      = "${var.az}"
  subnet_id              = "${var.subnet}"
}
