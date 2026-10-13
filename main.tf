locals {
  lb_name = "${var.name_prefix}-lb"

  environments = {
    blue = {
      tg_name       = "${var.name_prefix}-blue-tg"
      asg_name      = "${var.name_prefix}-blue-asg"
      template_name = "${var.name_prefix}-blue-template"
      title         = "Blue Environment"
    }
    green = {
      tg_name       = "${var.name_prefix}-green-tg"
      asg_name      = "${var.name_prefix}-green-asg"
      template_name = "${var.name_prefix}-green-template"
      title         = "Green Environment"
    }
  }
}

# ---------- Existing network resources ----------

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_names)

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_security_group" "ssh" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "group-name"
    values = [var.ssh_sg_name]
  }
}

data "aws_security_group" "http" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "group-name"
    values = [var.http_sg_name]
  }
}

data "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "group-name"
    values = [var.lb_sg_name]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------- Load balancer ----------

resource "aws_lb" "main" {
  name               = local.lb_name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [data.aws_security_group.lb.id]
  subnets            = [for s in data.aws_subnet.public : s.id]

  tags = {
    Name = local.lb_name
  }
}

resource "aws_lb_target_group" "env" {
  for_each = local.environments

  name     = each.value.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = each.value.tg_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.env["blue"].arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.env["green"].arn
        weight = var.green_weight
      }
    }
  }

  tags = {
    Name = "${local.lb_name}-http-listener"
  }
}

# ---------- Launch templates ----------

resource "aws_launch_template" "env" {
  for_each = local.environments

  name          = each.value.template_name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      data.aws_security_group.ssh.id,
      data.aws_security_group.http.id
    ]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>${each.value.title}</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${each.key}-instance"
    }
  }

  tags = {
    Name = each.value.template_name
  }
}

# ---------- Auto Scaling groups ----------

resource "aws_autoscaling_group" "env" {
  for_each = local.environments

  name                = each.value.asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = [for s in data.aws_subnet.public : s.id]
  target_group_arns   = [aws_lb_target_group.env[each.key].arn]
  health_check_type   = "ELB"

  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.env[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = each.value.asg_name
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}