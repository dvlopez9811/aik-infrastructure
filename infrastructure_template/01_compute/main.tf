#Create AIK front-end Security Group
resource "aws_security_group" "aik-sg-front-end" {
    name        = "${var.sg-front-end}"
    description = "Security group for allowing traffic to portal"
    vpc_id      = "${var.vpc-id}"
    
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
    vpc_id      = "${var.vpc-id}"
    
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

#Create AIK back-end EC2 instance
resource "aws_instance" "aik-portal" {
    ami                    = "${var.aik-ami-id}"
    instance_type          = "${var.aik-instance-type}"
    key_name               = "${var.aik-key-name}"
    vpc_security_group_ids = ["${aws_security_group.aik-sg-back-end.id}"]
    subnet_id              = "${var.aik-public-subnet}"
    user_data              = "${data.template_file.back-end-user-data.rendered}"

    tags {
      Name = "${var.aik-back-end-instance-name}" 
    }
}

data "template_file" "back-end-user-data" {
    template = "${file("../scripts/backend.sh")}"
    
    vars = {
        endpoint = "${element(split(":",var.aik-db-endpoint), 0)}"
    }
}

#Create AIK Launch Configuration for AIK front-end instance
resource "aws_launch_configuration" "aik-launch-configuration" {
    name            = "${var.aik-front-end-instance-name}" 
    image_id        = "${var.aik-ami-id}"
    instance_type   = "${var.aik-instance-type}"
    security_groups = ["${aws_security_group.aik-sg-front-end.id}"]
    key_name        = "${var.aik-key-name}"
    
    user_data = "${data.template_file.front-end-user-data.rendered}"

    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "front-end-user-data" {
    template = "${file("../scripts/frontend.sh")}"
    
    vars = {
        backend = "${aws_instance.aik-portal.public_ip}"
    }
}

#Create AIK Application Load Balancer

#Create AIK Security Group for Application Load Balancer
resource "aws_security_group" "sg-alb" {
    
    name    = "${var.alb-security-group-name}"
    vpc_id  = "${var.vpc-id}"
    
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
resource "aws_alb" "aik-alb"{
    name                = "${var.alb-name}"
    subnets             = ["${var.aik-public-subnet}","${var.aik-second-public-subnet}"]
    security_groups     = ["${aws_security_group.sg-alb.id}"]
    
    tags {
        Name = "${var.alb-tag-name}"
    }
}

#Create Application Load Balancer Listener
resource "aws_alb_listener" "http" {
    load_balancer_arn = "${aws_alb.aik-alb.arn}"
    port              = "${var.alb-port}"
    protocol          = "${var.alb-protocol}"

    default_action = {
        target_group_arn ="${aws_alb_target_group.alb-target-group.arn}"
        type = "fixed-response"

        fixed_response = {
            content_type    = "text/plain"
            message_body    = "404: page not found"
            status_code     = 404
        }
    }
}

# Create Application Load Balancer Listener Rule
resource "aws_alb_listener_rule" "listener_rule" {
    depends_on = ["aws_alb_target_group.alb-target-group"]
    listener_arn = "${aws_alb_listener.http.arn}"
    priority     = 100
    
    condition {
        path_pattern {
           values = ["*"]
        }
    }
    
    action {
        type             = "forward"
        target_group_arn = "${aws_alb_target_group.alb-target-group.arn}"
    }
  
}

# Create Application Load Balancer Target Group
resource "aws_alb_target_group" "alb-target-group" {

    name        = "${var.alb-target-group-name}"
    port        = "${var.server-port}"
    protocol    = "HTTP"
    vpc_id      = "${var.vpc-id}"

    health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 5
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags {
        Name = "${var.alb-target-group}"
    }
  
}

#Create AIK Autoscaling Group
resource "aws_autoscaling_group" "aik-asg" {
    launch_configuration    = "${aws_launch_configuration.aik-launch-configuration.id}"
    min_size                = "${var.min-size}"
    max_size                = "${var.max-size}"
    vpc_zone_identifier     = ["${var.aik-public-subnet}","${var.aik-second-public-subnet}"]
    target_group_arns       = ["${aws_alb_target_group.alb-target-group.arn}"]

    lifecycle {
        create_before_destroy = true
    }

    tag = {
        key = "Name"
        value = "${var.aik-asg-name}"
        propagate_at_launch = true
    }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.aik-asg.id}"
  alb_target_group_arn   = "${aws_alb_target_group.alb-target-group.arn}"
}