resource "aws_ssm_document" "session_manager_prefs" {
  count           = module.context.enabled ? 1 : 0
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"
  tags            = module.context.tags

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = var.enable_log_to_s3 ? module.s3_session_manager_log_storage.bucket_id : ""
      s3EncryptionEnabled         = var.enable_log_to_s3 ? "true" : "false"
      cloudWatchLogGroupName      = var.enable_log_to_cloudwatch ? try(aws_cloudwatch_log_group.session_manager_log_group[0].name, "") : ""
      cloudWatchEncryptionEnabled = var.enable_log_to_cloudwatch ? "true" : "false"
      kmsKeyId                    = module.kms_key.key_id
      shellProfile = {
        linux   = var.linux_shell_profile == "" ? var.linux_shell_profile : ""
        windows = var.windows_shell_profile == "" ? var.windows_shell_profile : ""
      }
    }
  })
}
