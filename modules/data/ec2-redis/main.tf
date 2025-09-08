# EC2
resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_redis_id]
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
    sudo apt update
    sudo apt install -y redis-server
    sudo systemctl enable --now redis-server
    REDIS_CONF="/etc/redis/redis.conf"
    REDIS_PASSWORD="password"
    sudo sed -i 's/^bind .*/bind 0.0.0.0/' "$REDIS_CONF"
    if grep -q "^# requirepass" "$REDIS_CONF"; then
        sudo sed -i "s/^# requirepass .*/requirepass $REDIS_PASSWORD/" "$REDIS_CONF"
    else
        echo "requirepass $REDIS_PASSWORD" | sudo tee -a "$REDIS_CONF"
    fi
    sudo ufw allow 6379/tcp
    sudo systemctl restart redis-server
    redis-cli -a "$REDIS_PASSWORD" ping
    EOF

  tags = merge(var.tags, {
    Name = "${var.name}-redis"
  })
}