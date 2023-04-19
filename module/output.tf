output "lambda_function_name" {
  value = aws_lambda_function.tag_untagged_efs.function_name
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution.arn
}
