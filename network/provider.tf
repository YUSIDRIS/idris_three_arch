terraform {
  backend "s3" {
    bucket = "idristerraformstate"
    key    = "idris/state"
    region = "us-east-2"
    dynamodb_table = "idris_state_lock"
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

    }
  }
}

provider "aws" {
  region                   = "us-east-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "idris.tf"
}
