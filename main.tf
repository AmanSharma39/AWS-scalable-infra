terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "leafny_key" {
  key_name   = var.key_name
  public_key = file("leafny-key.pub")
}

resource "aws_security_group" "leafny_sg" {
  name        = "leafny-sg"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "leafny_web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.leafny_key.key_name
  security_groups             = [aws_security_group.leafny_sg.name]
  associate_public_ip_address = true
  user_data                   = file("init.sh")

  tags = {
    Name = "leafny-web"
  }
}


resource "aws_ebs_volume" "leafny_data" {
  availability_zone = aws_instance.leafny_web.availability_zone
  size              = 10
  type              = "gp2"

  tags = {
    Name = "leafny-ebs"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.leafny_data.id
  instance_id = aws_instance.leafny_web.id
  force_detach = true
}


resource "aws_eip" "leafny_eip" {
  instance = aws_instance.leafny_web.id
  # vpc = true
}

resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cw_profile" {
  name = "CloudWatchAgentProfile"
  role = aws_iam_role.cloudwatch_agent_role.name
}


resource "aws_ami_from_instance" "leafny_ami" {
  name               = "leafny-ami"
  source_instance_id = aws_instance.leafny_web.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "leafny-ami"
  }
}

resource "aws_launch_template" "leafny_template" {
  name_prefix   = "leafny-template"
  image_id      = aws_ami_from_instance.leafny_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.leafny_key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.cw_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.leafny_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "leafny-asg-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "leafny_asg" {
  name                      = "leafny-asg"
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.leafny_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "leafny-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_on_cpu" {
  name                   = "scale-on-cpu"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.leafny_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU > 70%"
  

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.leafny_asg.name
  }
}