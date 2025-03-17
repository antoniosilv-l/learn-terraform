terraform {
  backend "s3" {
    bucket                  = "terraform-sgon-example-state"
    key                     = "stage/data-stores/mysql/terraform.tfstate"
    region                  = "us-east-2"

    dynamodb_table          = "terraform-sgon-example-locks"
    encrypt                 = true
  }
}

provider "aws" {
  region                    = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix         = "terraform-sgon-up-and-running"
  engine                    = "mysql"
  allocated_storage         = 10
  instance_class            = "db.t3.micro"
  skip_final_snapshot       = true
  db_name                   = "example_database"

  username                  = var.db_username
  password                  = var.db_password
}