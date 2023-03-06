#!/bin/bash

##################################
## for installing the SSM-agent ##
##################################
yum update -y
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

########################################
## for installing the kibana(v7.17.8) ##
########################################
yum update -y
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.17.8-x86_64.rpm
sudo rpm --install kibana-7.17.8-x86_64.rpm
private_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml
echo "server.port: "5601""  >> /etc/kibana/kibana.yml
echo "elasticsearch.hosts: [\"http://${elasticsearch_endpoint}:9200\"]"  >> /etc/kibana/kibana.yml
systemctl enable --now kibana

################################
## for installing the grafana ##
################################
echo "+++installing Grafana++"
sudo amazon-linux-extras install epel -y
sudo yum install -y chromium
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-8.5.21-1.x86_64.rpm 
sudo yum install grafana-enterprise-8.5.21-1.x86_64.rpm -y

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo grafana-cli plugins install grafana-image-renderer
sudo sed -i 's/;provider =/provider = local/' /etc/grafana/grafana.ini
sudo sed -i "s@;domain = localhost@domain=http://social-grafana-qa.tothenew.net@"  /etc/grafana/grafana.ini
sudo sed -i "s@;root_url = %(protocol)s://%(domain)s:%(http_port)s/@root_url=http://social-grafana-qa.tothenew.net@"  /etc/grafana/grafana.ini
sudo sed -i "s/;http_port = 3000/http_port = 3000/"  /etc/grafana/grafana.ini
sudo sed -i "s/;protocol = http/protocol = http/"  /etc/grafana/grafana.ini
sudo systemctl restart grafana-server
