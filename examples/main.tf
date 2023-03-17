module "visualization" {
    source = "../"
    instance_type_visualization = "t3.medium"
    volume_size_visualization = "30"
    pem_key_name = "visualization"
    environment = "qa"
    vpc_cidr_block = ""
    vpc_id = ""
    subnet_id = ""
    elasticsearch_endpoint = ""
}