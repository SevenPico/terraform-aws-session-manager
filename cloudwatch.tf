resource "aws_cloudwatch_log_group" "session_manager_log_group" {
  count             = module.context.enabled ? 1 : 0
  name              = "/aws/ssm/${module.context.id}"
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = module.kms_key.key_arn

  tags = module.context.tags
}