output "vpc_id" {
    value = aws_vpc.threetier.id
}
output "public_subnet" {
    value = aws_subnet.public[*]
}