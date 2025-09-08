variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

#SSH 접근 CIDR
# variable "ssh_allowed_cidrs" {
#   type    = list(string)
#   default = []
# }

# 공통 EC2 사양 (기본값은 '최저 사양')
variable "ami_id" {
  type        = string
  description = "기본 AMI ID (각 서비스별 *_ami_id가 없으면 이 값을 사용)"
}

variable "instance_type" {
  type        = string
  description = "기본 인스턴스 타입 (서비스별 *_instance_type이 없으면 이 값을 사용)"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "EC2 키페어 이름 (없으면 null)"
  default     = null
}

variable "volume_size" {
  type        = number
  description = "기본 EBS 볼륨 크기(GB) (서비스별 *_volume_size가 없으면 이 값을 사용)"
  default     = 8
}

variable "volume_type" {
  type        = string
  description = "기본 EBS 볼륨 타입"
  default     = "gp3"
}

variable "volume_iops" {
  type        = number
  description = "EBS IOPS (gp3 기본값 사용 시 null)"
  default     = null
}

# --- RDS 전용 오버라이드(선택) ---
variable "rds_username" {
  type        = string
  description = "RDS DB username"
}

variable "rds_password" {
  type        = string
  description = "RDS DB password"
  sensitive   = true
}

variable "rds_db_name" {
  type        = string
  default     = "order_platform"
}

variable "engine_version" {
  type        = string
  default     = "16.9"
}

variable "instance_class" {
  type        = string
  default     = "db.m5.large"
}

variable "proxy_name" {
  type        = string
  default     = "OrderRdsProxy"
}

# --- Redis 전용 오버라이드(선택) ---
variable "redis_ami_id" {
  type        = string
  description = "Redis용 AMI ID (없으면 공통 ami_id 사용)"
  default     = null
}

variable "redis_instance_type" {
  type        = string
  description = "Redis용 인스턴스 타입 (없으면 공통 instance_type 사용)"
  default     = null
}

variable "rds_instance_class" {
  type = string
  default = "db.m5.large"
}


variable "redis_key_name" {
  type        = string
  description = "Redis용 키페어 (없으면 공통 key_name 사용)"
  default     = null
}

variable "redis_volume_size" {
  type        = number
  description = "Redis용 EBS 크기 (없으면 공통 volume_size 사용)"
  default     = null
}

variable "redis_volume_type" {
  type        = string
  description = "Redis용 EBS 타입 (없으면 공통 volume_type 사용)"
  default     = null
}

#--DOC DB --
variable "docdb_username"         { type = string }
variable "docdb_password"         { type = string }
variable "docdb_instance_class"{
  type = string
  default = "db.t3.medium"
}
