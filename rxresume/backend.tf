terraform {
  backend "s3" {
    bucket         = "rxresume3bucket"  
    key            = "terraform.tfstate"   
    region         = "us-east-2"           
    encrypt        = true             
    dynamodb_table = "terraform-lock" 
  }
}

