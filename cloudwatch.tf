resource "aws_cloudwatch_log_group" "session_manager_log_group" {
  count             = module.context.enabled ? 1 : 0
  name_prefix       = "${var.cloudwatch_log_group_name}-"
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = module.kms_key.key_id

  tags = var.tags
}