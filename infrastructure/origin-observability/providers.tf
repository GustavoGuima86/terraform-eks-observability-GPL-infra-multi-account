provider "aws" {
  region = var.region
  alias  = "main"
}

provider "aws" {
  alias  = "gustavo_account_2"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.gustavo_account_2}:role/CrossAccountAdminRole"
  }
}