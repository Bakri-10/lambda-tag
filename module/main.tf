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

# Define IAM policy documents
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:CreateTags",
    ]
    resources = ["*"]
  }
}

# Create IAM policies from the policy documents
resource "aws_iam_policy" "assume_role_policy" {
  name        = "lambda_assume_role_policy"
  policy      = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "ec2_permissions_policy" {
  name        = "lambda_ec2_permissions_policy"
  policy      = data.aws_iam_policy_document.ec2_permissions.json
}

# Create the IAM role and attach policies to it
resource "aws_iam_role" "lambda_execution" {
  name = var.iam_role_name

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "assume_role_attachment" {
  policy_arn = aws_iam_policy.assume_role_policy.arn
  role       = aws_iam_role.lambda_execution.name
}

resource "aws_iam_role_policy_attachment" "ec2_permissions_attachment" {
  policy_arn = aws_iam_policy.ec2_permissions_policy.arn
  role       = aws_iam_role.lambda_execution.name
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
