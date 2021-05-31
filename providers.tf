provider "aws" {
  alias      = "region_back"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}

provider "aws" {
  alias      = "region_front"
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}