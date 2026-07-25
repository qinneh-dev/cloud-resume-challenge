# 1. zipping code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend" 
  output_path = "${path.module}/lambda_function.zip"
}

# creating iam role
resource "aws_iam_role" "lambda_role" {
  name = "VisitorCounterLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. creating iam policy
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "VisitorCounterDynamoDBAccess"
  description = "Allows Lambda to update the DynamoDB table and write logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:UpdateItem",
          
        ]
        Resource = aws_dynamodb_table.visitors_counter.arn
      },
      #for cloudwatch
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# attaching policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}


resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "VisitorCounter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10" 
  architectures    = ["arm64"]
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}