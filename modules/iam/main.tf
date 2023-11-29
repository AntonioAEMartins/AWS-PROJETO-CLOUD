resource "aws_iam_role" "cloud_iam_role" {
  name               = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloud_ec2_policy" {
  name   = var.iam_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "rds:Describe*",
          # "cloudwatch:PutMetricData",
          # "cloudwatch:GetMetricData",
          # "cloudwatch:ListMetrics"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect   = "Allow",
        Resource = "*" // You may want to restrict this to specific secret ARNs
      }
    ]
  })
}

resource "aws_iam_instance_profile" "cloud_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.cloud_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cloud_iam_role_policy" {
  role       = aws_iam_role.cloud_iam_role.name
  policy_arn = aws_iam_policy.cloud_ec2_policy.arn
}
