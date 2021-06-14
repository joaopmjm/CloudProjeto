data "aws_vpc" "default_back" {
	provider    = aws.region_back
	default = true
}

module "backend_sg" {
	source = "terraform-aws-modules/security-group/aws"
	providers = {
		aws = aws.region_back
	}

	name        = "backend-sg"
	description = "Backends SG."
	vpc_id      = data.aws_vpc.default_back.id

	ingress_with_cidr_blocks = [
	{
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		description = "Allow SSH"
		cidr_blocks = "0.0.0.0/0"
	},
	{
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		description = "Allow HTTP"
		cidr_blocks = "0.0.0.0/0"
	},
	{
		from_port   = 8000
		to_port     = 8000
		protocol    = "tcp"
		description = "Allow HTTPS"
		cidr_blocks = "0.0.0.0/0"
	},
	]

	egress_with_cidr_blocks = [
	{
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		description = "Allow all outgoing traffic"
		cidr_blocks = "0.0.0.0/0"
	}
	]

	tags = {
		Owner = "joaopmjm"
		Name  = "backend-sg-component"
	}
}

module "backend_sg_db" {
	source = "terraform-aws-modules/security-group/aws"
	providers = {
		aws = aws.region_back
	}

	name        = "backend-sg-db"
	description = "Backends SG."
	vpc_id      = data.aws_vpc.default_back.id

	ingress_with_cidr_blocks = [
	{
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		description = "Allow SSH"
		cidr_blocks = "0.0.0.0/0"
	},
	{
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		description = "Allow HTTP"
		cidr_blocks = "0.0.0.0/0"
	},
	{
		from_port   = 8080
		to_port     = 8080
		protocol    = "tcp"
		description = "Allow HTTPS"
		cidr_blocks = "0.0.0.0/0"
	},
	]

	egress_with_cidr_blocks = [
	{
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		description = "Allow all outgoing traffic"
		cidr_blocks = "0.0.0.0/0"
	}
	]

	tags = {
		Owner = "joaopmjm"
		Name  = "backend-sg-component"
	}
}