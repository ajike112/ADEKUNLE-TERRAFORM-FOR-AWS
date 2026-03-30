
#### Variables (types of variables)
## The first requirement for variables is to identify the type of the data you are creating a variable for.
## You have to be descriptive in naming your variable. ## How do I reference a variable? it would be (var.variable name)

## Create a variable for ami
variable "ami_id" {
  type = string
  description = "ami id"
  default = "ami-02dfbd4ff395f2a1b"
}

## Create a variable for vpc cidr_block
variable "vpc_cidr" {
  type = string
  description = "vpc cidr"
  default = "10.0.0.0/16"
}

## Create a variable for instance_type
variable "instance_type" {
  type = string
  description = "instance type"
  default = "t2.micro"
}

##Create a variable for subnet cidr1
variable "subnet_cidr_1" { 
    type = string 
    description = "CIDR block for the main subnet" 
    default = "10.0.1.0/24"
 }

##Create a variable for subnet cidr2
variable "subnet_cidr_2" { 
    type = string 
    description = "CIDR block for the main subnet" 
    default = "10.0.3.0/24"
 }

##Create a variable for subnet cidr3
variable "subnet_cidr_3" { 
    type = string 
    description = "CIDR block for the main subnet" 
    default = "10.0.5.0/24"
 }

##Create a variable for subnet cidr4
variable "subnet_cidr_4" { 
    type = string 
    description = "CIDR block for the main subnet" 
    default = "10.0.7.0/24"
 }
