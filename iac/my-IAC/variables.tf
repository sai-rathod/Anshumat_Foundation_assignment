variable "vpc_cidr" {
    description = "provide vpc cidr"
    type = string
}
variable "env" {
    description = "provide env type eg:dev,staging,prod"
    type = string
    default = "dev"
}
variable "public_subnet_cidr" {
    description = "provide public_subnet cidr"
    type = string
}
variable "private_subnet_cidr" {
    description = "provide private_subnet cidr"
    type = string
}
variable "sg_ports" {
    description = "list of ports you want to allow"
    type = list(number)
}
variable "ami" {
    description = "provide ami for instance"
    type = string
}
variable "dynamodb_details" {
  type = map(string)
  default = {
    "name" = "my-table"
    "hash_key" = "TempID"
    "type" = "S"
  }
}
