terraform {
  backend "s3" {
    bucket  = "REPLACE_WITH_TERRAFORM_STATE_BUCKET"
    key     = "tripare/dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

