# Create Security group that allows Traffic from the internet to the application LoadBalancer 

resource "aws_security_group" "alb_sg" {
  name        = "yt-alb-sg"
  description = "Security group for application Load Balancer "
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yt-alb-sg"
  }
}

# Create Security group from Appliation Load Balancer to Ec2 instance   
resource "aws_security_group" "ec2_sg" {
  name        = "yt-ec2-sg"
  description = "Security group for Ec2 instance "
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yt-ec2-sg"
  }
}

# Create the application Load Balancer

resource "aws_lb" "app_lb" {
  name               = "yt-app-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.igw_vpc]

}

# Create a target Group for the Application load Balancer

resource "aws_lb_target_group" "alb_ec2_tg" {
  name     = "yt-web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id

  tags = {
    Name = "yt_alb_ec2_tg"
  }

}

resource "aws_lb_listener" "alb_listener" {

  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
  tags = {
    Name = "yt_alb_listener"
  }
}

# Create a Launch template to the ec2 instance

resource "aws_launch_template" "ec2_launch_template" {
  name          = "yt-web-server"
  image_id      = "ami-004a0173a724e2261"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }
  user_data = filebase64("userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "yt-instance-web_server"
    }
  }
}

# creating the auto Scaling Group 
resource "aws_autoscaling_group" "ec2_asg" {
  max_size            = 3
  min_size            = 2
  desired_capacity    = 2
  name                = "yt-web-server-asg"
  target_group_arns   = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  health_check_type = "EC2"
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}