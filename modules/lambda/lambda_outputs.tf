output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.check_ecr_lambda.arn
}
