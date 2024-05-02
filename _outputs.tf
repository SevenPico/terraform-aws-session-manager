output "logs_bucket_name" {
  value = module.s3_session_manager_log_storage.bucket_id
}

output "logs_bucket_arn" {
  value = module.s3_session_manager_log_storage.bucket_arn
}

output "cloudwatch_log_group_arn" {
  value = try(aws_cloudwatch_log_group.session_manager_log_group[0].arn, "")
}

output "kms_key_arn" {
  value = module.kms_key.key_arn
}

output "iam_role_arn" {
  value = module.session_manager_iam_assume_role.arn
}

output "iam_profile_name" {
  value = module.session_manager_iam_assume_role.instance_profile
}

output "ssm_security_group" {
  value = try(aws_security_group.ssm_sg[0].id, "")
}

output "vpc_endpoint_ssm" {
  value = try(aws_vpc_endpoint.ssm[0].id, "")
}

output "vpc_endpoint_ec2messages" {
  value = try(aws_vpc_endpoint.ec2messages[0].id, "")
}

output "vpc_endpoint_ssmmessages" {
  value = try(aws_vpc_endpoint.ssmmessages[0].id, "")
}

output "vpc_endpoint_s3" {
  value = try(aws_vpc_endpoint.s3[0].id, "")
}

output "vpc_endpoint_logs" {
  value = try(aws_vpc_endpoint.logs[0].id, "")
}

output "vpc_endpoint_kms" {
  value = try(aws_vpc_endpoint.kms[0].id, "")
}
