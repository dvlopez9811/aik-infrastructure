variable "vpc-cidr" {
    default = "10.0.0.0/16"
}

variable "vpc-name" {
    default = "automatizacion-aik-vpc-RicardoSebastianAndres"
}

variable "rtb-name" {
    default = "automatizacion-aik-rtb-RicardoSebastianAndres"
}

variable "aws-availability-zones" {
    default = "us-west-2a,us-west-2b"
}

variable "subnet-name" {
    default = "automatizacion-aik-subnet-RicardoSebastianAndres"
}

variable "rtb-association-name" {
    default = "automatizacion-aik-rtb-association-RicardoSebastianAndres"
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
    default = "automatizacion-devops-RicardoSebastianAndres"
}

variable "aik-back-end-instance-name" {
    default = "automatizacion-aik-back-end-instance-RicardoSebastianAndres"
}
