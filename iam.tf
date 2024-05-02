data "aws_iam_policy_document" "session_manager_s3_cloudwatch_log_access_policy_doc" {
  count = module.context.enabled ? 1 : 0
  # checkov:skip=CKV_AWS_111: ADD REASON
  # A custom policy for S3 bucket access
  # https://docs.aws.amazon.com/en_us/systems-manager/latest/userguide/setup-instance-profile.html#instance-profile-custom-s3-policy
  statement {
    sid = "S3BucketAccessForSessionManager"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    resources = [
      module.s3_session_manager_log_storage.bucket_arn,
      "${module.s3_session_manager_log_storage.bucket_arn}/*",
    ]
  }

  statement {
    sid = "S3EncryptionForSessionManager"

    actions = [
      "s3:GetEncryptionConfiguration",
    ]

    resources = [
      module.s3_session_manager_log_storage.bucket_arn
    ]
  }


  # A custom policy for CloudWatch Logs access
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/permissions-reference-cwl.html
  statement {
    sid = "CloudWatchLogsAccessForSessionManager"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }

  statement {
    sid = "KMSEncryptionForSessionManager"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = [module.kms_key.key_arn]
  }
}


module "session_manager_iam_assume_role" {
  source     = "registry.terraform.io/SevenPicoForks/iam-role/aws"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["session", "manager", "assume", "role"]

  assume_role_actions      = ["sts:AssumeRole"]
  assume_role_conditions   = []
  instance_profile_enabled = true
  managed_policy_arns      = ["${local.arn_prefix}:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = ""
  policy_document_count    = 1
  policy_documents         = [try(data.aws_iam_policy_document.session_manager_s3_cloudwatch_log_access_policy_doc[0].json, "")]
  principals = {
    Service : [
      "ec2.amazonaws.com",
    ]
  }
  role_description = "Session Manager Assume Role"
  use_fullname     = true
}

