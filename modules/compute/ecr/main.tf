resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repositories)
  name                 = "order-${each.key}"
  image_tag_mutability = var.image_mutability

  # true: 이미지를 push할 때 AWS ECR이 보안 스캔을 자동 실행
  # image_scanning_configuration {
  #   scan_on_push = var.scan_on_push
  # }

  # 이미지 저장 암호화
  # encryption_configuration {
  #   encryption_type = var.encryption_type
  #   kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  # }

  tags = var.tags
}

# Lifecycle Policy: latest 1개 보존 + 전체 2개만 유지
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = toset(var.repositories)
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 1 image tagged 'latest'"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only last 2 images overall (tagged or untagged)"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 2
        }
        action = { type = "expire" }
      }
    ]
  })
}