output "aik-vpc-id" {
  value = "${aws_vpc.aik-vpc.id}"
}

output "aik-public-subnet" {
  value = "${aws_subnet.aik-public-subnet.id}"
}

output "aik-second-public-subnet" {
  value = "${aws_subnet.aik-second-public-subnet.id}"
}

output "aik-db-endpoint" {
  value = "${aws_db_instance.aik-db.endpoint}"
}