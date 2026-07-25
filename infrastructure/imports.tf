import {
  to = aws_s3_bucket.website_bucket
  id = "omaralqinneh-resume-bucket-eu"
}

import {
  to = aws_dynamodb_table.visitors_counter
  id = "VisitorCount"
}

import {
  to = aws_iam_role.lambda_role
  id = "VisitorCounterLambdaRole"
}

import {
  to = aws_key_pair.runner_key
  id = "runner-key"
}

import {
  to = aws_security_group.runner_sg
  id = "sg-01c229116b62d6632"
}

import {
  to = aws_cloudfront_origin_access_control.oac
  id = "E1D3F8GFLRIM17"
}