variable "vpc-cidr" {
    default = "10.0.0.0/16"
}

variable "vpc-name" {
    default = "aik-vpc-RicardoSebastianAndres"
}

variable "rtb-name" {
    default = "aik-rtb-RicardoSebastianAndres"
}

variable "aws-availability-zones" {
    default = "us-east-1a,us-east-1b"
}

variable "subnet-name" {
    default = "aik-subnet-RicardoSebastianAndres"
}

variable "rtb-association-name" {
    default = "aik-rtb-association-RicardoSebastianAndres"
}

variable "sg-front-end" {
    default = "aik-sg-front-end"
}

variable "sg-back-end" {
    default = "aik-sg-back-end"
}

variable "elb-name" {
    default = "aik-elb"
}

variable "aik-ami-id" {
    default = "ami-0fc61db8544a617ed" 
}

variable "aik-instance-type" {
    default = "t2.micro"
}

variable "min-size" {
    default = "1"
}

variable "max-size" {
    default = "2"
}

variable "db-subnetgroup-name" {
  default = "aik-main-subnet-group"
}

variable "aik-key-name" {
    default = "devops-RicardoSebastianAndres"
}

variable "aik-back-end-instance-name" {
    default = "aik-back-end-instance-RicardoSebastianAndres"
}

