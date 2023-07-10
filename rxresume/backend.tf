terraform {
  backend "s3" {
    bucket         = "rxresume3bucketmax1"  
    key            = "terraform.tfstate"   
    region         = "us-east-2"           
    encrypt        = true             
    dynamodb_table = "terraform-lock" 
  }
}



