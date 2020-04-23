provider "aws" {
    region = "us-west-2"
}

#Create aik vpc
resource "aws_vpc" "aik-vpc" {
    cidr_block = "${var.vpc-cidr}"
    tags {
        Name = "${var.vpc-name}"
    }
}

#Create aik internet gateway
resource "aws_internet_gateway" "aik-igw" {
  vpc_id = "${aws_vpc.aik-vpc.id}"
}

#Create aik route table
resource "aws_route_table" "rtb-public" {
    vpc_id = "${aws_vpc.aik-vpc.id}"
   
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.aik-igw.id}"
    }
    
    tags {
        Name = "${var.rtb-name}"
    }
}

#Create aik subnet
resource "aws_subnet" "aik-public-subnet" {
    vpc_id                  = "${aws_vpc.aik-vpc.id}"
    cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 1)}"
    availability_zone       = "${element(split(",", var.aws-availability-zones), count.index)}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.subnet-name}"
    }
}

#Create aik route table association
resource "aws_route_table_association" "public" {
    subnet_id       = "${aws_subnet.aik-public-subnet.id}"
    route_table_id  = "${aws_route_table.rtb-public.id}"
}

#Create aik front-end security group
resource "aws_security_group" "aik-sg-front-end" {
    name        = "${var.sg-front-end}"
    description = "Security group for allowing traffic to portal"
    vpc_id      = "${aws_vpc.aik-vpc.id}"
    
    ingress {
        from_port   = "3030"
        to_port     = "3030"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Create aik back-end security group
resource "aws_security_group" "aik-sg-back-end" {
    name        = "${var.sg-back-end}"
    description = "Security group for allowing traffic from front-end"
    vpc_id      = "${aws_vpc.aik-vpc.id}"
    
    ingress {
        from_port   = "3000"
        to_port     = "3000"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Create aik elastic load balancer
resource "aws_elb" "aik-elb" {
    name            = "${var.elb-name}"
    security_groups = ["${aws_security_group.aik-sg-front-end.id}"]
    subnets         = ["${aws_subnet.aik-public-subnet.id}"]

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 30
        target              = "HTTP:3030/"
    }

    listener{
        lb_port             = 3030
        lb_protocol         = "tcp"
        instance_port       = 3030
        instance_protocol   = "tcp"
    }
}

#Create aik launch configuration for aik front-end instance
resource "aws_launch_configuration" "aik-launch-configuration" {
    image_id        = "${var.aik-ami-id}"
    instance_type   = "${var.aik-instance-type}"
    security_groups = ["${aws_security_group.aik-sg-front-end.id}"]

    user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y git 
        #Clone salt repo
        git clone https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure
        #Install Salstack
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #Put custom minion config in place (for enabling masterless mode)
        sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/
        echo -e 'grains:\n roles:\n  - frontend' > /etc/salt/minion.d/grains.conf
        ## Trigger a full Salt run
        sudo salt-call state.apply
        EOF

        lifecycle {
            create_before_destroy = true
        }
}

#Create aik autoscaling group
resource "aws_autoscaling_group" "aik-asg" {
    launch_configuration    = "${aws_launch_configuration.aik-launch-configuration.id}"
    availability_zones      = ["${var.aws-availability-zones}"]

    health_check_type = "ELB"

    min_size = "${var.min-size}"
    max_size = "${var.max-size}"
}

#Create aik back-end ec2 instance
resource "aws_instance" "aik-portal" {

  ami                    = "${var.aik-ami-id}"
  instance_type          = "${var.aik-instance-type}"
  key_name               = "${var.aik-key-name}"
  vpc_security_group_ids = ["${aws_security_group.aik-sg-back-end.id}"]
  subnet_id              = "${aws_subnet.aik-public-subnet.id}"
  tags {
      Name = "${var.aik-back-end-instance-name}" 
  }

  user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y git 
        #Clone salt repo
        git clone https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure
        #Install Salstack
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #Put custom minion config in place (for enabling masterless mode)
        sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/
        echo -e 'grains:\n roles:\n  - backend' > /etc/salt/minion.d/grains.conf
        ## Trigger a full Salt run
        sudo salt-call state.apply
        EOF

}


#Create aik database
resource "aws_db_instance" "aik-db" {
    allocated_storage       = 20   
    storage_type            = "gp2"   
    engine              = "mysql"   
    engine_version       = "5.7"   
    instance_class       = "db.t2.micro"   
    name                 = "dbAIK"   
    username             = "root"   
    password             = "password"   
    parameter_group_name = "default.mysql5.7"   
    db_subnet_group_name   = "${aws_db_subnet_group.aik-db-subnet-group.id}" 
}

resource "aws_db_subnet_group" "aik-db-subnet-group" {   
    name        = "${var.db-subnetgroup-name}"     
    subnet_ids  = ["${aws_subnet.aik-public-subnet.id}"] 
}
