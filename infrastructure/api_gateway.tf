#http api gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "ResumeVisitorAPI"
  protocol_type = "HTTP"

#configuring cors
  cors_configuration {
    allow_origins = ["https://omaralqinneh.me"]
    allow_methods = [ "POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

# integration between gatway and lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  
  integration_uri    = aws_lambda_function.visitor_counter.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /visitors"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# deploying api
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# api permission 
resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# output url
output "api_endpoint" {
  description = "The URL of the API Gateway"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/visitors"
}