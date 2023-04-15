# Module Inputs:

variable "function_name" {
  description = "The name of the Lambda function to create."
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
}

variable "lambda_handler" {
  description = "The function entrypoint in your code."
  type        = string
}

variable "key" {
  description = "The key for an environment variable to set for the Lambda function."
  type        = string
}

variable "value" {
  description = "The value for an environment variable to set for the Lambda function."
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role to create and attach to the Lambda function."
  type        = string
}

variable "region" {
  description = "The AWS region where the resources will be created."
  type        = string
}
