provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}

provider "onepassword" {
  account = var.onepassword_account
}

