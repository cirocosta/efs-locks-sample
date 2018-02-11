# Creates a new empty file system in EFS.
resource "aws_efs_file_system" "main" {
  tags {
    Name = "locks-test-fs"
  }
}

# Creates a mount target of EFS in a specified subnet
# such that our instances can connect to it.
resource "aws_efs_mount_target" "main" {
  file_system_id  = "${aws_efs_file_system.main.id}"
  subnet_id       = "${var.subnet}"
  security_groups = ["${aws_security_group.efs.id}"]
}

# Allows both ingress and eggress for port 2049 (nfs)
# such that our instances are able to get to the mount
# target in the AZ.
resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.default.cidr_block}",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.default.cidr_block}",
    ]
  }

  tags {
    Name = "allow_nfs-ec2"
  }
}
