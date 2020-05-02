provider "aws" {
    region = "${var.aws-region}"
}

#Create AIK VPC
resource "aws_vpc" "aik-vpc" {
    cidr_block = "${var.vpc-cidr}"
    
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

#Create AIK front-end Security Group
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

    tags {
        Name = "${var.sg-name}"
    }
}

#Create AIK back-end Security Group
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

    tags {
        Name = "${var.sg-second-name}"
    }
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

    tags {
        Name = "${var.aik-db-name}"
    }
}

#Create AIK back-end EC2 instance
resource "aws_instance" "aik-portal" {
    ami                    = "${var.aik-ami-id}"
    instance_type          = "${var.aik-instance-type}"
    key_name               = "${var.aik-key-name}"
    vpc_security_group_ids = ["${aws_security_group.aik-sg-back-end.id}"]
    subnet_id              = "${aws_subnet.aik-public-subnet.id}"
    
    user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y git 
        #Clone salt repo
        git clone -b development https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure
        #Install Salstack
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #Put custom minion config in place (for enabling masterless mode)
        sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/
        sudo sh -c "echo export ENDPOINT=${element(split(":",aws_db_instance.aik-db.endpoint), 0)} >> /etc/profile"
        echo -e 'grains:\n roles:\n  - backend' | sudo tee /etc/salt/minion.d/grains.conf
        ## Trigger a full Salt run
        sudo salt-call state.apply
        EOF

    tags {
      Name = "${var.aik-back-end-instance-name}" 
    }
}

#Create AIK front-end EC2 instance
resource "aws_instance" "aik-front" {
    ami                    = "${var.aik-ami-id}"
    instance_type          = "${var.aik-instance-type}"
    key_name               = "${var.aik-key-name}"
    vpc_security_group_ids = ["${aws_security_group.aik-sg-front-end.id}"]
    subnet_id              = "${aws_subnet.aik-public-subnet.id}"
    
    user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y git 
        #Clone salt repo
        git clone -b development https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure
        #Install Salstack
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #Put custom minion config in place (for enabling masterless mode)
        sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/
        sudo sh -c "echo export BACKEND=${aws_instance.aik-portal.public_ip} >> /etc/profile"
        echo -e 'grains:\n roles:\n  - frontend' | sudo tee /etc/salt/minion.d/grains.conf
        ## Trigger a full Salt run
        sudo salt-call state.apply
        EOF

    tags {
      Name = "${var.aik-front-end-instance-name}" 
    }
}
/*
#Create AIK Launch Configuration for AIK front-end instance
resource "aws_launch_configuration" "aik-launch-configuration" {
    name            = "${var.aik-front-end-instance-name}" 
    image_id        = "${var.aik-ami-id}"
    instance_type   = "${var.aik-instance-type}"
    security_groups = ["${aws_security_group.aik-sg-front-end.id}"]
    key_name        = "${var.aik-key-name}"
    
    user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y git 
        #Clone salt repo
        git clone -b development https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure
        #Install Salstack
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #Put custom minion config in place (for enabling masterless mode)
        sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/
        sudo sh -c "echo export BACKEND=${aws_instance.aik-portal.public_ip} >> /etc/profile"
        echo -e 'grains:\n roles:\n  - frontend' | sudo tee /etc/salt/minion.d/grains.conf
        ## Trigger a full Salt run
        sudo salt-call state.apply
        EOF

    lifecycle {
        create_before_destroy = true
    }

}

#Create AIK Application Load Balancer

#Create AIK Security Group for Application Load Balancer
resource "aws_security_group" "sg-alb" {
    
    name    = "${var.alb-security-group-name}"
    vpc_id  = "${aws_vpc.aik-vpc.id}"
    
    # Allow inbound HTTP requests
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow all outbound requests
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

     tags {
        Name = "${var.sg-third-name}"
    }
}

#Create AIK Application Load Balancer
resource "aws_lb" "aik-alb"{
    name                = "${var.alb-name}"
    load_balancer_type  = "${var.load_balancer_type}"
    subnets             = ["${aws_subnet.aik-public-subnet.id}","${aws_subnet.aik-second-public-subnet.id}"]
    security_groups     = ["${aws_security_group.sg-alb.id}"]

    tags {
        Name = "${var.alb-tag-name}"
    }
}

#Create Application Load Balancer Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = "${aws_lb.aik-alb.arn}"
    port              = "${var.alb-port}"
    protocol          = "${var.alb-protocol}"

    default_action = {
        type = "fixed-response"

        fixed_response = {
            content_type    = "text/plain"
            message_body    = "404: page not found"
            status_code     = 404
        }
    }
}

# Create Application Load Balancer Target Group
resource "aws_lb_target_group" "alb-target-group" {

    name        = "${var.alb-target-group-name}"
    port        = "${var.server-port}"
    protocol    = "HTTP"
    vpc_id      = "${aws_vpc.aik-vpc.id}"

    health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags {
        Name = "${var.alb-target-group}"
    }
  
}

# Create Application Load Balancer Listener Rule
resource "aws_lb_listener_rule" "listener_rule" {
    listener_arn = "${aws_lb.aik-alb.arn}"
    priority     = 100
    
    condition {
        path_pattern {
           values = ["*"]
        }
    }
    
    action {
        type             = "forward"
        target_group_arn = "${aws_lb_target_group.alb-target-group.arn}"
    }
  
}

#Create AIK Autoscaling Group
resource "aws_autoscaling_group" "aik-asg" {
    launch_configuration    = "${aws_launch_configuration.aik-launch-configuration.id}"
    min_size                = "${var.min-size}"
    max_size                = "${var.max-size}"
    vpc_zone_identifier     = ["${aws_subnet.aik-public-subnet.id}","${aws_subnet.aik-second-public-subnet.id}"]
    target_group_arns       = ["${aws_lb_target_group.alb-target-group.arn}"]

    lifecycle {
        create_before_destroy = true
    }

    tags {
        Name = "${var.aik-asg-name}"
    }
}
*/
