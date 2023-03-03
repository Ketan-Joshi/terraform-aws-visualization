module "prometheus" {
    source = "../"
    instance_type_visulization = "t3.medium"
    volume_size_visulization = "30"
    pem_key_name = "visulization"
    environment = "qa"
    vpc_cidr_block = ""
    vpc_id = ""
    subnet_id = ""
    elasticsearch_endpoint = ""
}