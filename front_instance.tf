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
	public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "frontend-instance" {
	provider               = aws.region_front
	depends_on             = [module.frontend_sg]
	vpc_security_group_ids = [module.frontend_sg.security_group_id]
	ami                    = data.aws_ami.ubuntu18_back.id
	instance_type          = "t2.micro"
	subnet_id              = "subnet-51976d6f"
	private_ip             = "172.31.48.50"
	key_name               = "joaopmjm_ssh_back"
	user_data = file("./scripts/front.sh")
	tags = {
		Owner = "joaopmjm"
		Name  = "frontend-instance"
	}
}