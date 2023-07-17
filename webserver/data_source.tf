data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "idristerraformstate"
    key = "network/state"
    region = "us-east-2"
   
  }
}

data "aws_ami" "amazon_image" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*.0-kernel-6.1-x86_64"]
  }
   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}