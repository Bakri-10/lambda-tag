resource "aws_lambda_function" "tag_untagged_instances" {
  function_name = var.function_name
  role         = aws_iam_role.lambda_execution.arn
  runtime      = var.runtime
  handler      = var.lambda_handler
  filename     = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      KEY   = var.key
      VALUE = var.value
    }
  }
}


resource "aws_iam_role" "lambda_execution" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Sid = "EC2Permissions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution.name
}

resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tag_untagged_instances.function_name
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
}

data "aws_caller_identity" "current" {}

locals {
  lambda_function_zip_file = join("/", [path.root, "lambda_function.zip"])
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = local.lambda_function_zip_file
  output_path = "${path.module}/lambda_function.zip"
}
