output "private_ip" {
  value = aws_instance.visualization.private_ip
}
output "instance_id" {
  value = aws_instance.visualization.id
}
output "visualization_pem_file" {
  value = tls_private_key.ssh_private_key.private_key_pem
  sensitive = true
}
