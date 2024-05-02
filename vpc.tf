data "aws_vpc" "selected" {
  count = module.context.enabled && var.vpc_endpoints_enabled ? 1 : 0
  id    = var.vpc_id
}

data "aws_route_table" "selected" {
  count     = var.vpc_endpoints_enabled ? length(var.subnet_ids) : 0
  subnet_id = sort(var.subnet_ids)[count.index]
}

# SSM, EC2Messages, and SSMMessages endpoints are required for Session Manager
resource "aws_vpc_endpoint" "ssm" {
  count             = module.context.enabled && var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${local.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = module.context.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  count             = module.context.enabled && var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${local.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = module.context.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count             = module.context.enabled && var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${local.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = module.context.tags
}

# To write session logs to S3, an S3 endpoint is needed:
resource "aws_vpc_endpoint" "s3" {
  count        = module.context.enabled && var.vpc_endpoints_enabled && var.enable_log_to_s3 ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
  tags         = module.context.tags
}

# Associate S3 Gateway Endpoint to VPC and Subnets
resource "aws_vpc_endpoint_route_table_association" "private_s3_route" {
  count           = module.context.enabled && var.vpc_endpoints_enabled && var.enable_log_to_s3 ? 1 : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = data.aws_vpc.selected[0].main_route_table_id
}

resource "aws_vpc_endpoint_route_table_association" "private_s3_subnet_route" {
  count           = module.context.enabled && var.vpc_endpoints_enabled && var.enable_log_to_s3 ? length(data.aws_route_table.selected) : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = data.aws_route_table.selected[count.index].id
}

# To write session logs to CloudWatch, a CloudWatch endpoint is needed
resource "aws_vpc_endpoint" "logs" {
  count             = module.context.enabled && var.vpc_endpoints_enabled && var.enable_log_to_cloudwatch ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${local.region}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = module.context.tags
}

# To Encrypt/Decrypt, a KMS endpoint is needed
resource "aws_vpc_endpoint" "kms" {
  count             = module.context.enabled && var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${local.region}.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.ssm_sg.*.id

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = module.context.tags
}
