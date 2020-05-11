variable "aws-region" {
  default = "us-west-2"
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

#Tags name

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

#tfvar
variable "aik-vpc-id" {

}

variable "aik-public-subnet"  {

}

variable "aik-second-public-subnet" {

}

variable "aik-db-endpoint" {

}