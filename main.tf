module "tag_lambda" {
  source = "./module"

  function_name = "my-lambda-function"
  iam_role_name = "my-lambda-role"
  runtime = "python3.8"
  lambda_handler = "index.lambda_handler"
  key = "MyKey"
  value = "MyValue"
  region = "us-east-1"
}