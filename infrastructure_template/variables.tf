variable "aws-region" {
    default = "us-west-2"
}

variable "vpc-cidr" {
    default = "10.0.0.0/16"
}

variable "route-cidr" {
    default = "0.0.0.0/0"
}

variable "aws-availability-zones" {
    default = "us-west-2a,us-west-2b"
}

variable "sg-front-end" {
    default = "aik-sg-front-end"
}

variable "sg-back-end" {
    default = "aik-sg-back-end"
}

variable "aik-ami-id" {
    default = "ami-0d6621c01e8c2de2c" 
}

variable "aik-instance-type" {
    default = "t2.micro"
}

variable "aik-front-end-instance-name" {
    default = "automatizacion-aik-front-end-instance-RicardoSebastianAndres"
}

variable "aik-key-name" {
    default = "automatizacion-devops-RicardoSebastianAndres"
}

variable "alb-security-group-name" {
    default = "aik-sg-alb"
}

variable "alb-name" {
    default = "aik-alb"
}

variable "load_balancer_type" {
    default = "application"
}

variable "min-size" {
    default = "1"
}

variable "max-size" {
    default = "2"
}

variable "server-port" {
    default = "3030"
}

variable "alb-target-group-name" {
    default = "aik-target-group"
}

variable "alb-port" {
    default = 80
}

variable "alb-protocol" {
    default = "HTTP"
}

variable "db-subnetgroup-name" {
    default = "aik-main-subnet-group"
}

variable "rds-security-group-name" {
    default = "aik-sg-rds"
}

variable "rds-engine" {
    default = "mysql"
  
}

variable "rds-engine-version" {
    default = "5.7"
}

variable "rds-instance-class" {
    default = "db.t2.micro"
  
}

variable "rds-name" {
    default = "dbAIK"
}

variable "rds-username" {
    default = "root"
}

variable "rds-password" {
    default = "password"
}

# Tags name
variable "vpc-name" {
    default = "automatizacion-igw-name-RicardoSebastianAndres"
}

variable "igw-name" {
    default = "automatizacion-aik-vpc-RicardoSebastianAndres"
}

variable "rtb-name" {
    default = "automatizacion-aik-rtb-RicardoSebastianAndres"
}

variable "subnet-name" {
    default = "automatizacion-aik-subnet-RicardoSebastianAndres"
}

variable "second-subnet-name" {
    default = "automatizacion-aik-second-subnet-RicardoSebastianAndres"
}

variable "sg-name" {
    default = "automatizacion-aik-sg-back-end-RicardoSebastianAndres"
}

variable "sg-second-name" {
    default = "automatizacion-aik-sg-front-end-RicardoSebastianAndres"
}

variable "aik-back-end-instance-name" {
    default = "automatizacion-aik-back-end-instance-RicardoSebastianAndres"
}

variable "sg-third-name" {
    default = "automatizacion-aik-alb-sg-RicardoSebastianAndres"
}

variable "alb-tag-name" {
    default = "aik-alb-RicardoSebastianAndres"
}

variable "alb-target-group" {
    default = "aik-alb-target-group-RicardoSebastianAndres"
}

variable "aik-asg-name" {
    default = "automatizacion-asg-RicardoSebastianAndres"
}

variable "aik-subnet-rds-name" {
    default = "automatizacion-db-subnet-group-RicardoSebastianAndres"
}

variable "sg-rds-tag-name" {
    default = "automatizacion-aik-rds-sg-RicardoSebastianAndres"
}

variable "aik-db-name" {
    default = "automatizacion-db-RicardoSebastianAndres"
}
