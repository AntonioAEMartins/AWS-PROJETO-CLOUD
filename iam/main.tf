resource "aws_iam_role" "cloud_iam_role" {
  name               = var.iam_role_name
  assume_role_policy = var.iam_role_assume_role_policy
}

resource "aws_iam_policy" "cloud_ec2_policy" {
  name   = var.iam_policy_name
  policy = var.iam_policy_policy
}

resource "aws_iam_instance_profile" "cloud_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.cloud_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cloud_iam_role_policy" {
  role       = aws_iam_role.cloud_iam_role.name
  policy_arn = aws_iam_policy.cloud_ec2_policy.arn
}
