terraform {
  backend "s3" {
    bucket = "terraform-sgon-example-state"
    key = "workspaces-example/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-sgon-example-locks"
    encrypt = true
  }
}

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}