data "aws_ami" "ubuntu18_front" {
	provider    = aws.region_front
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu-*"]
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
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe0lEbqZzzu0+SkNBRub6233zVDR1pCNwphl4YQ/A+AKxbKD84lLKKT3dDQVSm1gKjwSZdStwhJqDVEslo7OFnk8HuES7pdQNd3DPe9O29RVl0bBvAhYdGIo7/B08vQyUnNuYA+dyZEwJIAbVj5SI1/84rBEyKShVEqb6/WG6gZq2ruvgXaeuGqHzVuLZBYf4Uu6GC3CPYff3ZYRQbN7/5kXnePaC9yxr8A+/VCi2fqYs9sd/wClCUursdfF3rooOy8+A7rapxMP7D2Tap1l/TkgDOTpiUKwwH7WPIVguBS7dL5f9zI6vb98/ctrLgSHyjmHU2PKa3GuuUUj7rIECp joao@G7-joao"
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
	security_groups = [module.frontend_sg.security_group_id]
	key_name        = "joaopmjm_ssh_front"

	user_data = data.template_file.front_script_data.rendered

	lifecycle {
		create_before_destroy = true
	}
}

module "frontend_elb" {
  source = "terraform-aws-modules/elb/aws"
  providers = {
    aws = aws.region_front
  }
  depends_on =  [module.frontend_sg]

  name = "front-elb"

  subnets         = ["subnet-4d2f5a42", "subnet-13fa4b4f", "subnet-7ebe0d50"]
  security_groups = [module.frontend_sg.security_group_id]
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
  value = module.frontend_elb.elb_dns_name
}