output "vpc_id" {
  value = aws_vpc.my-vpc.id
}
output "public_instance_ip" {
    value = aws_instance.public-instance.public_ip
}
output "dynamodb_table" {
    value = aws_dynamodb_table.my-db.name
}