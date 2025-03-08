resource "aws_iam_policy" "remotion_s3_list_buckets" {
  name        = "remotion-s3-list-buckets-policy"
  description = "Policy to allow s3:ListAllMyBuckets"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "0"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "remotion_s3_bucket_actions" {
  name        = "remotion-s3-bucket-actions-policy"
  description = "Policy to allow S3 actions on remotionlambda-* buckets"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "1"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:ListBucket",
          "s3:PutBucketAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::remotionlambda-*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "remotion_lambda_invoke" {
  name        = "remotion-lambda-invoke-policy"
  description = "Policy to allow lambda:InvokeFunction on remotion-render-*"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "2"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:*:*:function:remotion-render-*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "remotion_logs_create_log_group" {
  name        = "remotion-logs-create-log-group-policy"
  description = "Policy to allow logs:CreateLogGroup for /aws/lambda-insights"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "3"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda-insights"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "remotion_logs_lambda_stream" {
  name        = "remotion-logs-lambda-stream-policy"
  description = "Policy to allow logs:CreateLogStream and logs:PutLogEvents on Lambda log groups"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "4"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/remotion-render-*",
          "arn:aws:logs:*:*:log-group:/aws/lambda-insights:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "remotion_lambda_role" {
  name               = "remotion-lambda-role"
  description        = "Role for Lambda to access S3, Logs, and invoke Lambda functions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the policies to the role
resource "aws_iam_role_policy_attachment" "remotion_attach_s3_list_buckets" {
  role       = aws_iam_role.remotion_lambda_role.name
  policy_arn = aws_iam_policy.remotion_s3_list_buckets.arn
}

resource "aws_iam_role_policy_attachment" "remotion_attach_s3_bucket_actions" {
  role       = aws_iam_role.remotion_lambda_role.name
  policy_arn = aws_iam_policy.remotion_s3_bucket_actions.arn
}

resource "aws_iam_role_policy_attachment" "remotion_attach_lambda_invoke" {
  role       = aws_iam_role.remotion_lambda_role.name
  policy_arn = aws_iam_policy.remotion_lambda_invoke.arn
}

resource "aws_iam_role_policy_attachment" "remotion_attach_logs_create_log_group" {
  role       = aws_iam_role.remotion_lambda_role.name
  policy_arn = aws_iam_policy.remotion_logs_create_log_group.arn
}

resource "aws_iam_role_policy_attachment" "remotion_attach_logs_lambda_stream" {
  role       = aws_iam_role.remotion_lambda_role.name
  policy_arn = aws_iam_policy.remotion_logs_lambda_stream.arn
}
