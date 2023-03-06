variable "instance_type_visualization" {
    description = "This defines Visualization (Grafana + Kibana) Instance Size/Type"
    type        = string
    default     = ""
}
variable "volume_size_visualization" {
    description = "This defines Visualization (Grafana + Kibana) Instance Root Volume Size"
    type        = number
    default     = "30"
}
variable "pem_key_name" {
    description = "This defines Pem Key Name"
    type        = string
    default     = ""
}
variable "environment" {
    description = "This defines the Environment Tag"
    type        = string
    default     = ""
}
variable "vpc_id" {
    description = "This defines Visualization (Grafana + Kibana) Instance VPC ID"
    type        = string
    default     = ""
}
variable "vpc_cidr_block" {
    description = "This defines Visualization (Grafana + Kibana) Instance VPC CIDR Block"
    type        = string
    default     = ""
}
variable "subnet_id" {
    description = "This defines Visualization (Grafana + Kibana) Instance VPC Subnet ID"
    type        = string
    default     = ""
}
variable "elasticsearch_endpoint" {
    description = "This defines Elasticsearch Endpoint so that Kibana can connect with it"
    type        = string
    default     = ""
}
