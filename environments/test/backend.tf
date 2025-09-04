terraform {
  backend "s3" {
    bucket         = "order-platform-dev-tfstate"
    key            = "network/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "order-platform-dev-tf-lock"
    encrypt        = true
  }
}
