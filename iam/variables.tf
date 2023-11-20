variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "instance_role"
}

variable "iam_role_assume_role_policy" {
  description = "Assume role policy for the IAM role"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "cloud_ec2_policy"
}

variable "iam_policy_policy" {
  description = "IAM policy document for the IAM policy"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
  default     = "cloud_instance_profile"
}