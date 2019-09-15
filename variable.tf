variable "aws_region" {
    description = "The AWS region"
    default = ""
}

variable "aws_profile" {
    description = "The AWS credentials profile"
    default = ""
}

variable "ami-id" {
  description = "This is AMI ID"
  default = ""
}

variable "key_name" {
    description = "EC2 Key Pair"
    default = ""
}
variable "private_key" {
    description = "EC2 Key Pair Private Key Location"
    default = ""
}
variable "cidrblock" {
    description = "VPC cidr block"
    default = ""
}
variable "subnet1_address_space" {
    description = "Subnet cidr block"
    default = ""
}
variable "subnet2_address_space" {
    description = "Subnet cidr block"
    default = ""
}
variable "subnet3_address_space" {
    description = "Subnet cidr block"
    default = ""
}

