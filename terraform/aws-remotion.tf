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

resource "aws_iam_user" "remotion_user" {
  name = "remotion-user"
}

resource "aws_iam_access_key" "remotion_user_access_key" {
  user = aws_iam_user.remotion_user.name
}

output "remotion_user_access_key_id" {
  value = aws_iam_access_key.remotion_user_access_key.id
  sensitive = true
}

output "remotion_user_secret_access_key" {
  value = aws_iam_access_key.remotion_user_access_key.secret
  sensitive = true
}

resource "aws_iam_user_policy" "remotion_user_policy" {
  name = "remotion-user-policy"
  user = aws_iam_user.remotion_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "HandleQuotas"
        Effect    = "Allow"
        Action    = [
          "servicequotas:GetServiceQuota",
          "servicequotas:GetAWSDefaultServiceQuota",
          "servicequotas:RequestServiceQuotaIncrease",
          "servicequotas:ListRequestedServiceQuotaChangeHistoryByQuota"
        ]
        Resource  = ["*"]
      },
      {
        Sid       = "PermissionValidation"
        Effect    = "Allow"
        Action    = [
          "iam:SimulatePrincipalPolicy"
        ]
        Resource  = ["*"]
      },
      {
        Sid       = "LambdaInvokation"
        Effect    = "Allow"
        Action    = [
          "iam:PassRole"
        ]
        Resource  = [
          "arn:aws:iam::*:role/remotion-lambda-role"
        ]
      },
      {
        Sid       = "Storage"
        Effect    = "Allow"
        Action    = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:CreateBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutBucketAcl",
          "s3:DeleteBucket",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutLifecycleConfiguration"
        ]
        Resource  = [
          "arn:aws:s3:::remotionlambda-*"
        ]
      },
      {
        Sid       = "BucketListing"
        Effect    = "Allow"
        Action    = [
          "s3:ListAllMyBuckets"
        ]
        Resource  = ["*"]
      },
      {
        Sid       = "FunctionListing"
        Effect    = "Allow"
        Action    = [
          "lambda:ListFunctions",
          "lambda:GetFunction"
        ]
        Resource  = ["*"]
      },
      {
        Sid       = "FunctionManagement"
        Effect    = "Allow"
        Action    = [
          "lambda:InvokeAsync",
          "lambda:InvokeFunction",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:PutFunctionEventInvokeConfig",
          "lambda:PutRuntimeManagementConfig",
          "lambda:TagResource"
        ]
        Resource  = [
          "arn:aws:lambda:*:*:function:remotion-render-*"
        ]
      },
      {
        Sid       = "LogsRetention"
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy"
        ]
        Resource  = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/remotion-render-*"
        ]
      },
      {
        Sid       = "FetchBinaries"
        Effect    = "Allow"
        Action    = [
          "lambda:GetLayerVersion"
        ]
        Resource  = [
          "arn:aws:lambda:*:678892195805:layer:remotion-binaries-*",
          "arn:aws:lambda:*:580247275435:layer:LambdaInsightsExtension*"
        ]
      },
      {
        Sid    = "SessionTokenAccess"
        Effect = "Allow"
        Action = ["sts:GetSessionToken"]
        Resource = ["*"]
      }
    ]
  })
}

# Get the current AWS region
data "aws_region" "current" {}

# Create the S3 bucket with dynamic region name
resource "aws_s3_bucket" "remotionlambda" {
  bucket = "remotionlambda-${data.aws_region.current.name}"

  tags = {
    Name        = "remotionlambda-${data.aws_region.current.name}"
    Environment = "Production"
  }
}

output "remotion_bucket_name" {
  value = aws_s3_bucket.remotion_bucket.bucket
  description = "The name of the S3 bucket created for Remotion."
}
