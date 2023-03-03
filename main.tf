resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ssh_key" {
  key_name   = var.pem_key_name
  public_key = tls_private_key.ssh_private_key.public_key_openssh
  provisioner "local-exec" { # This will create the pem where the terraform will run!!
    command = "rm -f ./${var.pem_key_name}.pem && echo '${tls_private_key.ssh_private_key.private_key_pem}' > ./${var.pem_key_name}.pem && chmod 400 ${var.pem_key_name}.pem"
  }
}
data "template_file" "userdata" {
  template = file("${path.module}/visulization.sh")
  vars = {
    elasticsearch_endpoint = var.elasticsearch_endpoint
  }
}
resource "aws_instance" "visulization" {
  ami = "ami-0b5eea76982371e91"
  instance_type = var.instance_type_visulization
  user_data = data.template_file.userdata.rendered
  key_name = var.pem_key_name
  subnet_id = var.subnet_id
  disable_api_termination = true
  vpc_security_group_ids = [aws_security_group.visulization_sg.id]
  # associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = var.volume_size_visulization
  }
  depends_on = [
    aws_key_pair.ssh_key
  ]
  tags = {
    Name = "nw-social-visulization-${var.environment}"
  }
}
resource "aws_security_group" "visulization_sg" {
  name = "nw-social-visulization-${var.environment}-sg"
  vpc_id =  var.vpc_id
  ingress {
    description = "ingress rules"
    cidr_blocks = [var.vpc_cidr_block]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [var.vpc_cidr_block]
    from_port = 5601
    protocol = "tcp"
    to_port = 5601
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [var.vpc_cidr_block]
    from_port = 3000
    protocol = "tcp"
    to_port = 3000
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags = {
    Name = "nw-social-visulization-${var.environment}-sg"
  }
}