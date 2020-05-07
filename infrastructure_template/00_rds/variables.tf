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

variable "aik-subnet-rds-name" {
  default = "automatizacion-db-subnet-group-RicardoSebastianAndres"
}

variable "sg-rds-tag-name" {
  default = "automatizacion-aik-rds-sg-RicardoSebastianAndres"
}

variable "aik-db-name" {
  default = "automatizacion-db-RicardoSebastianAndres"
}

# tfvar

variable "rds-name" {
}

variable "rds-username" {
}

variable "rds-password" {
}

