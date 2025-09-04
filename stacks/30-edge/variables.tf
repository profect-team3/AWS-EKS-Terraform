variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

# ALB
variable "services" {
  type = map(object({
    port  = number
    paths = list(string)
  }))
}

variable "health_check_path" {
  description = "공통 헬스체크 경로"
  type        = string
  default     = "/actuator/health"
}

variable "lambda_allowed_function_arns" {
  type    = list(string)
  default = []
}