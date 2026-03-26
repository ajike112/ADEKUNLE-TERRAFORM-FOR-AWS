
#### Variables (types of variables)
## The first requirement for variables is to identify the type of the data you are creating a variable for.
## You have to be descriptive in naming your variable. ## How do I reference a variable? it would be (var.variable name)

## Create a variable for ami
variable "ami_id" {
  type = string
  description = "ami id"
  default = "ami-02dfbd4ff395f2a1b"
}

## Create a variable for cidr_block
variable "cidr_block" {
  type = string
  description = "cidr block"
  default = "10.0.0.0/16"
}

## Create a variable for instance_type
variable "instance_type" {
  type = string
  description = "instance type"
  default = "t2.micro"
}

