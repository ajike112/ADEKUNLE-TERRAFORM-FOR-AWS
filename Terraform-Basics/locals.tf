
## Declaring local values for vpc
## key: AnyName(local)
## value: Specific value for your local
 locals {
  vpc_id = aws_vpc.main.id
}