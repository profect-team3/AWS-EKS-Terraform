# EC2 for MongoDB Client (DocumentDB 접속용)
resource "aws_instance" "mongo_client" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_mongo_id] # DocumentDB SG와 통신 가능해야 함
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    iops        = var.volume_iops
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    sudo apt-get update
    sudo apt-get install -y wget curl gnupg
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-mongosh
    mongosh --version
    wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
    EOF

  tags = merge(var.tags, {
    Name = "${var.name}-mongo-client"
  })
}
