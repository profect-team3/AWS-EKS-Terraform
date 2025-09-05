resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repositories)
  name                 = "${var.name}-ecr-${each.key}"
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

# Lifecycle Policy: latest 태그 보존 + 최근 2개 이미지 보존
resource "aws_ecr_lifecycle_policy" "this" {
  for_each             = toset(var.repositories)
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = concat(
      [
        for i, p in var.keep_tag_prefixes : {
        rulePriority = i + 1
        description  = "Keep at least 1 image for tag prefix ${p}"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = [p]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = { type = "expire" }
      }
      ],
      [
        {
          rulePriority = length(var.keep_tag_prefixes) + 1
          description  = "Keep last ${var.keep_any_last} any images"
          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = var.keep_any_last
          }
          action = { type = "expire" }
        }
      ]
    )
  })
}
