#------------------------------------------------------------------------------
# Session Manager Kms Key
#------------------------------------------------------------------------------
data "aws_iam_policy_document" "session_manager_kms_key_policy_doc" {
  count = module.context.enabled && var.create_kms_key ? 1 : 0
  # checkov:skip=CKV_AWS_111: todo reduce perms on key
  # checkov:skip=CKV_AWS_109: ADD REASON
  statement {
    sid = "KMS Key Default"
    principals {
      type        = "AWS"
      identifiers = ["${local.arn_prefix}:iam::${local.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]

    resources = ["*"]

  }

  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]
    condition {
      test     = "ArnEquals"
      values   = ["${local.arn_prefix}:logs:${local.region}:${local.account_id}:/aws/ssm/${module.context.id}"]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }

}

module "kms_key" {
  source  = "SevenPicoForks/kms-key/aws"
  version = "2.0.0"
  context = module.context.self
  enabled = module.context.enabled && var.create_kms_key

  alias                    = ""
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = try(data.aws_iam_policy_document.session_manager_kms_key_policy_doc[0].json, "")
}