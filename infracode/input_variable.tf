provider "aws" {
   region     = "us-east-2"
   access_key = "**********"
   secret_key = "**************************"
}

resource "aws_instance" "ec2_example" {

   ami           = "ami-07062e2a343acc423"
   instance_type =  var.instance_type
   count         = var.instance_count

   tags = {
           Name = "Terraform EC2"
   }
}

variable "instance_type" {
   description = "Instance type t2.micro"
   type        = string
   default     = "t2.micro"
}

variable "instance_count" {
   description = "EC2 Instance count"
   type        = number
   default     = 2
}


