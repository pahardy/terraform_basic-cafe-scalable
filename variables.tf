variable "region" {
  description = "The AWS region into which to deploy resources"
  type = string
  default = "ca-central-1"
}

variable "cafe-ami" {
  description = "The AMI on which to install the cafe app"
  type = string
  default = "ami-0a2e7efb4257c0907"
}

#Getting the default VPC ID and populating it in a variable
data "aws_vpc" "default-vpc" {
  default = true
}

#Getting the subnet IDs
data "aws_subnets" "asg-subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

variable "asg-max" {
  description = "Maximum ASG size"
  type = number
  default = 5
}

variable "asg-min" {
  description = "Minimum ASG size"
  type = number
  default = 3
}

variable "asg-desired" {
  description = "Desired ASG size"
  type = number
  default = 3
}

variable "http-port" {
  description = "Port for HTTP traffic"
  type = number
  default = 80
}

variable "lb-protocol" {
  description = "LB protocol"
  type = string
  default = "HTTP"
}

variable "cidr_blocks" {
  description = "CIDR block for the SGs"
  type = string
  default = "0.0.0.0/0"
}

variable "db_username" {
  description = "Username for the backend DB"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "Password for the backend DB"
  type = string
  sensitive = true
}