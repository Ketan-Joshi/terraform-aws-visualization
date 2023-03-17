#!/bin/bash

# environment variables
environment=${environment}

##################################
## for installing the SSM-agent ##
##################################
yum update -y
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

#################################
## for installing the CW-agent ##
#################################
cd /opt && wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm && rpm -U ./amazon-cloudwatch-agent.rpm

cat <<EOF >>/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent.json
{
        "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "cwagent"
        },
        "metrics": {
                "append_dimensions": {
                        "ImageId": "\$\{aws\:ImageId\}",
                        "InstanceId": "\$\{aws\:InstanceId\}",
                        "InstanceType": "\$\{aws\:InstanceType\}"
                },
                "metrics_collected": {
                        "disk": {
                                "measurement": [
                                        "used_percent"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        }
                },
                "aggregation_dimensions" : [ 
                        ["InstanceId", "InstanceType"]
                ]
        }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent.json
sudo systemctl restart amazon-cloudwatch-agent.service

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
grafana-cli plugins install grafana-x-ray-datasource

cat <<EOF >>/etc/grafana/grafana.ini
#################################### Paths ####################################
[paths]
data = /var/lib/grafana

#################################### Server ####################################
[server]
protocol = http
http_port = 3000
domain = https://social-grafana-$environment.tothenew.net/
root_url =https://social-grafana-$environment.tothenew.net/

#################################### Alerting ############################
[alerting]
enabled = true

#################################### External image storage ##########################
[external_image_storage]
provider = local

#################################### Grafana Image Renderer Plugin ##########################
[plugin.grafana-image-renderer]
rendering_ignore_https_errors = true
rendering_verbose_logging = debug
rendering_mode = default
EOF

sudo systemctl restart grafana-server
