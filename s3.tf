# ------------------------------------------------------------------------------
# S3 Session Manager Log Storage Context
# ------------------------------------------------------------------------------
module "s3_session_manager_log_storage_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["logs"]
}


# ------------------------------------------------------------------------------
# S3 Session Manager Log Storage IAM Policy
# ------------------------------------------------------------------------------
locals {
  s3_bucket_arn = "${local.arn_prefix}:s3:::${module.s3_session_manager_log_storage_context.id}"
}

#data "aws_iam_policy_document" "s3_log_storage" {
#  count = module.s3_session_manager_log_storage_context.enabled ? 1 : 0
#
#  statement {
#    sid = "SSMAccountIdAccess"
#    principals {
#      type        = "AWS"
#      identifiers = [try("", data.aws_elb_service_account.s3_log_storage.*.arn)]
#    }
#    effect = "Allow"
#    actions = [
#      "s3:PutObject"
#    ]
#    resources = ["${local.s3_bucket_arn}/*"]
#  }
#  statement {
#    sid = "LogDeliveryService"
#    principals {
#      type = "Service"
#      identifiers = [
#        "delivery.logs.amazonaws.com",
#      ]
#    }
#    effect    = "Allow"
#    actions   = ["s3:PutObject"]
#    resources = ["${local.s3_bucket_arn}/*"]
#    condition {
#      test     = "StringEquals"
#      variable = "s3:x-amz-acl"
#      values   = ["bucket-owner-full-control"]
#    }
#  }
#  statement {
#    sid    = "AWSLogDeliveryAclCheck"
#    effect = "Allow"
#    principals {
#      type = "Service"
#      identifiers = [
#        "delivery.logs.amazonaws.com",
#      ]
#    }
#    actions   = ["s3:GetBucketAcl"]
#    resources = ["${local.s3_bucket_arn}"]
#  }
#}


# ------------------------------------------------------------------------------
# S3 Log Storage
# ------------------------------------------------------------------------------
module "s3_session_manager_log_storage" {
  source  = "SevenPicoForks/s3-bucket/aws"
  version = "4.0.6"
  context = module.s3_session_manager_log_storage_context.self

  acl                          = "log-delivery-write"
  allow_encrypted_uploads_only = false
  allow_ssl_requests_only      = true
  enable_mfa_delete            = var.enable_mfa_delete
  force_destroy                = var.force_destroy
  ignore_public_acls           = true
  kms_master_key_arn           = module.kms_key.key_arn
  source_policy_documents      = var.s3_source_policy_documents #concat([one(data.aws_iam_policy_document.s3_log_storage[*].json)], var.s3_source_policy_documents)
  sse_algorithm                = module.kms_key.alias_arn == "" ? "AES256" : "aws:kms"

  s3_replication_enabled      = var.s3_replication_enabled
  s3_replication_rules        = var.s3_replication_rules
  s3_replication_source_roles = var.s3_replication_source_roles
  allowed_bucket_actions = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  grants                        = []
  lifecycle_configuration_rules = var.s3_lifecycle_configuration_rules
  logging = var.s3_access_logs_s3_bucket_id != null ? {
    bucket_name = var.s3_access_logs_s3_bucket_id
    prefix      = var.s3_access_logs_prefix_override
  } : null
  object_lock_configuration     = null
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  restrict_public_buckets       = true
  s3_object_ownership           = var.s3_object_ownership
  s3_replica_bucket_arn         = ""
  transfer_acceleration_enabled = false
  user_enabled                  = false
  versioning_enabled            = var.s3_versioning_enabled
  website_inputs                = null
  wait_time_seconds             = 12
}
