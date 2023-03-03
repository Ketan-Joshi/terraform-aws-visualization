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
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.3.6-1.x86_64.rpm
sudo yum install -y grafana-enterprise-9.3.6-1.x86_64.rpm

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
