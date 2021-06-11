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
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe0lEbqZzzu0+SkNBRub6233zVDR1pCNwphl4YQ/A+AKxbKD84lLKKT3dDQVSm1gKjwSZdStwhJqDVEslo7OFnk8HuES7pdQNd3DPe9O29RVl0bBvAhYdGIo7/B08vQyUnNuYA+dyZEwJIAbVj5SI1/84rBEyKShVEqb6/WG6gZq2ruvgXaeuGqHzVuLZBYf4Uu6GC3CPYff3ZYRQbN7/5kXnePaC9yxr8A+/VCi2fqYs9sd/wClCUursdfF3rooOy8+A7rapxMP7D2Tap1l/TkgDOTpiUKwwH7WPIVguBS7dL5f9zI6vb98/ctrLgSHyjmHU2PKa3GuuUUj7rIECp joao@G7-joao"
}

resource "aws_instance" "backend-instance" {
	provider               = aws.region_back
	depends_on             = [module.backend_sg]
	vpc_security_group_ids = [module.backend_sg.security_group_id]
	ami                    = data.aws_ami.ubuntu18_back.id
	instance_type          = "t2.micro"
	subnet_id              = "subnet-51976d6f"
	private_ip             = "172.31.48.4"
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
	private_ip             = "172.31.48.5"

	user_data = file("./scripts/docker_db.sh")
	tags = {
		Owner = "joaopmjm"
		Name  = "backend-db"
	}
}


