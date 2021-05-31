data "aws_ami" "ubuntu18_front" {
	provider    = aws.region_front
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}

	owners = ["903616414837"]
}

resource "aws_key_pair" "joaopmjm_ssh_front" {
	provider   = aws.region_front
	key_name   = "joaopmjm_ssh_front"
	public_key = file("C:/Users/joaopmjm/.ssh/id_rsa.pub")
}

data "template_file" "front_script_data" {
	template = file("./scripts/front.sh")
	vars = {
		IP_DO_BACK = aws_instance.backend-instance.public_ip
	}
}
resource "aws_launch_configuration" "front_lc" {
	provider   = aws.region_front
	depends_on = [module.frontend_sg, data.aws_ami.ubuntu18_front, aws_instance.backend-instance]

	name_prefix     = "frontend-lc-"
	image_id        = data.aws_ami.ubuntu18_front.id
	instance_type   = "t2.micro"
	security_groups = [module.frontend_sg.this_security_group_id]
	key_name        = "joaopmjm_ssh_front"

	user_data = data.template_file.front_script_data.rendered

	lifecycle {
		create_before_destroy = true
	}
}

module "front_asg" {
	source = "terraform-aws-modules/autoscaling/aws"
	providers = {
		aws = aws.region_front
	}
	depends_on = [module.frontend_sg, module.frontend_elb, data.aws_ami.ubuntu18_front]

	name = "frontend-asg"

	launch_configuration         = aws_launch_configuration.front_lc.name
	create_lc                    = false
	recreate_asg_when_lc_changes = true

	security_groups = [module.frontend_sg.this_security_group_id]
	load_balancers  = [module.frontend_elb.this_elb_id]


	asg_name                  = "front-asg"
	vpc_zone_identifier       = ["subnet-b9e8dfd1", "subnet-c1cd198d", "subnet-e7e4899d"]
	health_check_type         = "EC2"
	min_size                  = 1
	max_size                  = 3
	desired_capacity          = null
	wait_for_capacity_timeout = 0

	tags = [
		{
		key                 = "Owner"
		value               = "joaopmjm"
		propagate_at_launch = true
		},
		{
		key                 = "Name"
		value               = "front-asg-component"
		propagate_at_launch = true
		},
	]
}

resource "aws_autoscaling_policy" "new_instance" {
  provider               = aws.region_front
  depends_on             = [module.front_asg]
  name                   = "new_instance"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.front_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "webserver_cpu_alarm_up" {
  provider            = aws.region_front
  depends_on          = [module.front_asg, aws_autoscaling_policy.new_instance]
  alarm_name          = "webserver_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = module.front_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.new_instance.arn]
}

resource "aws_autoscaling_policy" "kill_instance" {
  provider               = aws.region_front
  depends_on             = [module.front_asg]
  name                   = "kill_instance"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.front_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "webserver_cpu_alarm_down" {
  provider            = aws.region_front
  depends_on          = [module.front_asg, aws_autoscaling_policy.kill_instance]
  alarm_name          = "webserver_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = module.front_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.kill_instance.arn]
}

module "frontend_elb" {
  source = "terraform-aws-modules/elb/aws"
  providers = {
    aws = aws.region_front
  }
  depends_on =  [module.frontend_sg]

  name = "front-elb"

  subnets         = ["subnet-b9e8dfd1", "subnet-c1cd198d", "subnet-e7e4899d"]
  security_groups = [module.frontend_sg.this_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 15
  }

  tags = {
    Owner = "joaopmjm"
    Name  = "front-elb"
  }
}

output "webserver_elb_dns_name" {
  value = module.frontend_elb.this_elb_dns_name
}