# Create a key making use of our dumb key under `./keys`
resource "aws_key_pair" "main" {
  key_name   = "efs-locks-test-key"
  public_key = "${file("./keys/key.rsa.pub")}"
}
