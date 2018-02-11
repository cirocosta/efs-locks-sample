variable "region" {
  description = "name of the region to put our resources - must have EFS"
  default     = "us-east-1"
}

variable "subnet" {
  description = "id of the subnet that will hold all our resources"
  default     = "subnet-2f635d02"
}

variable "az" {
  description = "name of the az where the subnet and resources will leave"
  default     = "us-east-1a"
}

variable "instance-type" {
  description = "type of instance to use"
  default     = "t2.micro"
}

provider "aws" {
  region  = "${var.region}"
  profile = "beld"
}

# No need to create a fresh VPC just for this test.
#
# ps.: if it's the case that you deleted the default VPC
#      for your region, this will fail and you'll need to
#      create a VPC and a subnet there.
data "aws_vpc" "default" {
  default = true
}

# Pick the latest ubuntu artful (17.10) ami released by the
# Canonical team.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-artful-17.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

output "efs-mount-target-dns" {
  description = "address of the mount target provisioned"
  value       = "${aws_efs_mount_target.main.0.dns_name}"
}

output "instance-public-ip" {
  description = "public IP of the instance"
  value       = "${aws_instance.main.public_ip}"
}
