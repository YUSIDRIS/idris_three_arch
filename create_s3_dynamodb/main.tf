resource "aws_s3_bucket" "teraform_state" {
  bucket = "idristerraformstate"
}

resource "aws_dynamodb_table" "state_lock" {
  name           = "idris_state_lock"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}