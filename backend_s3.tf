/*# "terraform backend" is used to save tfstate file in s3 buckets which is created saperatly before running this code
 Backend must remain commented until the Bucket
 and the DynamoDB table are created. 
 After the creation you can uncomment it,
 run "terraform init" and then "terraform apply" */

terraform {
  backend "s3" {
    bucket         = "sameer-practice-terraform-state-backend"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform_state"
    encrypt        = true  
  }
}

