#Define Outputs

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_sg" {
  value = aws_security_group.bastion.id
}

output "private_subnets" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "public_subnets" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "developer_key_name" {
  value = aws_key_pair.developer.key_name
}
