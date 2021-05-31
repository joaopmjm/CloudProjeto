data "aws_vpc" "default_front" {
	provider    = aws.region_front
	default = true
}

module "frontend_sg" {
	source = "terraform-aws-modules/security-group/aws"
	providers = {
		aws = aws.region_front
	}

	name        = "frontend-sg"
	description = "frontends SG."
	vpc_id      = data.aws_vpc.default_front.id

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
		Name  = "frontend-sg-component"
	}
}