data "aws_ami" "ubuntu18_back" {
	provider    = aws.region_back
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

resource "aws_key_pair" "joaopmjm_ssh_back" {
	provider   = aws.region_back
	key_name   = "joaopmjm_ssh_back"
	public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "backend-instance" {
	provider               = aws.region_back
	depends_on             = [module.backend_sg]
	vpc_security_group_ids = [module.backend_sg.security_group_id]
	ami                    = data.aws_ami.ubuntu18_back.id
	instance_type          = "t2.micro"
	subnet_id              = "subnet-51976d6f"
	private_ip             = "172.31.48.1"
	key_name               = "joaopmjm_ssh_back"
	user_data = file("./scripts/back.sh")
	tags = {
		Owner = "joaopmjm"
		Name  = "backend-instance"
	}
}

resource "aws_instance" "backend-instance-db" {
	provider               = aws.region_back
	depends_on             = [module.backend_sg_db]
	vpc_security_group_ids = [module.backend_sg_db.security_group_id]
	ami                    = data.aws_ami.ubuntu18_back.id
	instance_type          = "t2.micro"
	key_name               = "joaopmjm_ssh_back"
	subnet_id              = "subnet-51976d6f"
	private_ip             = "172.31.48.2"

	user_data = file("./scripts/docker_db.sh")
	tags = {
		Owner = "joaopmjm"
		Name  = "backend-db"
	}
}


