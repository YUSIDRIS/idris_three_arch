output "vpc_id" {
    value = aws_vpc.threetier.id
}
output "public_subnet_id" {
    value = aws_subnet.public[*].id
}
output "private_subnet_id" {
    value = aws_subnet.private[*].id
}
output "DATAbase_subnet_id" {
    value = aws_subnet.DATAbase[*].id
}
output "internet_gateway_id" {
    value = aws_internet_gateway.IGW.id
 }
 
output "nat_gateway_id" {
    value = aws_nat_gateway.nat[*].id
}
output "elasticip" {
    value = aws_eip.elastic[*]
}
output "public_route_table_id" {
    value = aws_route_table.public_route_table.id
}
output "private_route_table_id" {
    value = aws_route_table.private_route_table[*].id
}

