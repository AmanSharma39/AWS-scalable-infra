variable "aws_region" {
  default = "us-west-1"
}

variable "key_name" {
  default = "leafny-key"
}


variable "ami_id" {
  default = "ami-014e30c8a36252ae5"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-05f5a7483184094a6", "subnet-0c1adad3fbe3d9c94"]
}
