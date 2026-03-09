#!/bin/bash
# Update system
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E amazon-cloudwatch-agent.deb

# Create CloudWatch agent config
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'EOL'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/docker.log",
            "log_group_name": "/vitalaxis/application",
            "log_stream_name": "docker-{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/vitalaxis/system",
            "log_stream_name": "syslog-{instance_id}"
          }
        ]
      }
    },
    "log_stream_name": "vitalaxis-app-{instance_id}"
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "disk": {
        "measurement": [
          "disk_used_percent"
        ],
        "resources": [
          "/"
        ]
      }
    }
  }
}
EOL

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json \
  -s

# Pull and run the application
docker pull tayraps/vitalaxis:latest

# Create docker-compose.yml for easier management
cat > /home/ubuntu/docker-compose.yml << 'EOL'
version: '3'
services:
  app:
    image: tayraps/vitalaxis:latest
    ports:
      - "5000:5000"
    logging:
      driver: "awslogs"
      options:
        awslogs-group: "/vitalaxis/application"
        awslogs-region: "af-south-1"
        awslogs-stream: "app-$(hostname)"
    environment:
      DATABASE_URL: postgresql://${db_user}:${db_password}@${db_host}:5432/${db_name}
    restart: always
EOL

# Run the container
cd /home/ubuntu
docker-compose up -d

echo "✅ Application and CloudWatch agent installed successfully!"
