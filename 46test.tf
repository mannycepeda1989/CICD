resource "aws_api_gateway_stage" "stage" {
  count = var.publish_api ? 1 : 0

  rest_api_id = var.use_openapi ? aws_api_gateway_rest_api.openapi_rest_api[0].id : aws_api_gateway_rest_api.rest_api[0].id
  stage_name  = var.stage_name
  deployment_id = aws_api_gateway_deployment.deployment[0].id
  description   = var.stage_description

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.rest_api_access_log_group[0].arn
    format          = var.access_log_format
  }

  variables = var.stage_variables
  tags      = local.common_tags

  depends_on = [
    aws_api_gateway_account.rest_api_account[0],
    aws_cloudwatch_log_group.rest_api_exec_log_group[0]
  ]
}
