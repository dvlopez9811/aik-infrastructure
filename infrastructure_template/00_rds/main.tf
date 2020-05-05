provider "aws" {
    region = "${var.aws-region}"
}

#Create AIK VPC
resource "aws_vpc" "aik-vpc" {
    cidr_block = "${var.vpc-cidr}"
    enable_dns_hostnames = true

    tags {
        Name = "${var.vpc-name}"
    }
}

#Create AIK Internet Gateway
resource "aws_internet_gateway" "aik-igw" {
  vpc_id = "${aws_vpc.aik-vpc.id}"

  tags {
      Name = "${var.igw-name}"
  }
}

#Create AIK Route Table
resource "aws_route_table" "rtb-public" {
    vpc_id = "${aws_vpc.aik-vpc.id}"
   
    route {
        cidr_block = "${var.route-cidr}"
        gateway_id = "${aws_internet_gateway.aik-igw.id}"
    }
    
    tags {
        Name = "${var.rtb-name}"
    }
}

#Create AIK Subnet
resource "aws_subnet" "aik-public-subnet" {
    vpc_id                  = "${aws_vpc.aik-vpc.id}"
    cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 1)}"
    availability_zone       = "${element(split(",",var.aws-availability-zones), count.index)}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.subnet-name}"
    }
}

#Create second AIK Subnet
resource "aws_subnet" "aik-second-public-subnet" {
    vpc_id                  = "${aws_vpc.aik-vpc.id}"
    cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 3)}"
    availability_zone       = "${element(split(",",var.aws-availability-zones), count.index + 1)}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.second-subnet-name}"
    }
}

#Create AIK Route Table Association
resource "aws_route_table_association" "public" {
    subnet_id       = "${aws_subnet.aik-public-subnet.id}"
    route_table_id  = "${aws_route_table.rtb-public.id}"
}

#Create AIK Database

#Create Subnet Group for AIK Database
resource "aws_db_subnet_group" "aik-rds-private-subnet" {
    name        = "${var.db-subnetgroup-name}"
    subnet_ids  = ["${aws_subnet.aik-public-subnet.id}","${aws_subnet.aik-second-public-subnet.id}"]
    
    tags {
        Name = "${var.aik-subnet-rds-name}"
    }
}

#Create Security Group for AIK Database
resource "aws_security_group" "rds-sg" {
    name    = "${var.rds-security-group-name}"
    vpc_id  = "${aws_vpc.aik-vpc.id}"

    # Allow inbound requests
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
    # Allow all outbound traffic.
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "${var.sg-rds-tag-name}"
    }
}

# Create AIK Database
resource "aws_db_instance" "aik-db" {
    allocated_storage       = 20   
    storage_type            = "gp2"   
    engine                  = "${var.rds-engine}"   
    engine_version          = "${var.rds-engine-version}"   
    instance_class          = "${var.rds-instance-class}"   
    name                    = "${var.rds-name}"   
    username                = "${var.rds-username}"   
    password                = "${var.rds-password}"   
    parameter_group_name    = "default.mysql5.7"   
    db_subnet_group_name    = "${aws_db_subnet_group.aik-rds-private-subnet.id}" 
    vpc_security_group_ids  = ["${aws_security_group.rds-sg.id}"]
    skip_final_snapshot     = true
    publicly_accessible     = true

    tags {
        Name = "${var.aik-db-name}"
    }
}
