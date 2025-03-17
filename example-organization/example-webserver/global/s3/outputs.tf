output "s3_bucket_arn" {
  description               = "O ARN do bucket do S3"
  value                     = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
    description             = "O nome da tabela do DynamoDB"
    value                   = aws_dynamodb_table.terraform_locks.name
}