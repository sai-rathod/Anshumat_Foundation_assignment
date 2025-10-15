module "my-dev-module" {
    source = "./my-IAC"
    env = "dev"
    vpc_cidr = "10.10.0.0/16"
    public_subnet_cidr = "10.10.1.0/24"
    private_subnet_cidr = "10.10.2.0/24"
    sg_ports = [20,443,3000,8080,80]
    ami = "ami-02d26659fd82cf299"
    dynamodb_details = {
        name = "temp-table"
        hash_key = "TempID"
        type = "S"
    }
}
output "public_instance_ip" {
    value = module.my-dev-module.public_instance_ip
  
}
output "vpc_id" {
    value = module.my-dev-module.vpc_id
}
output "dynamodb_table" {
    value = module.my-dev-module.dynamodb_table
  
}
