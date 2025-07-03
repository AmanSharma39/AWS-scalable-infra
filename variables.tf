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
  default = ["subnet-xxxxxx", "subnet-xxxxxx"]
}
