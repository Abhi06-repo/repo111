provider "aws" {
  region = "ap-south-1"
}

# Generate an SSH key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/example-key.pem"
  file_permission = "0600"
}

# Register the public key with AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "example-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Launch an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0e35ddab05955cf57" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name

  tags = {
    Name = "ExampleInstance"
  }
}

# Output the instance's public IP
output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
