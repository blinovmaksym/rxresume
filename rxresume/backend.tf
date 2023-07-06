terraform {
  backend "s3" {
    bucket         = "rxresume3bucket_max"  
    key            = "terraform.tfstate"   
    region         = "us-east-1"           
    encrypt        = true             
    dynamodb_table = "terraform-lock" 
  }
}
