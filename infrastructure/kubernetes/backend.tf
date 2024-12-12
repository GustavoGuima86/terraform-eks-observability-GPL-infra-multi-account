terraform {
  backend "s3" {
    bucket         = "gustavo-terraform-backend"
    key            = "eks/observability/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock" # a1df9203e22f8cdd5509fd10bb42faa6
  }
}

