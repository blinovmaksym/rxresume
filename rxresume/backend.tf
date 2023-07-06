terraform {
  backend "s3" {
    bucket         = "rxresume3bucketmax"  
    key            = "terraform.tfstate"   
    region         = "us-east-1"           
    encrypt        = true             
    dynamodb_table = "terraform-lock" 
  }
}
