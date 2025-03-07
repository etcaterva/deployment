# SQS queues

resource "aws_sqs_queue" "eas_secret_santa" {
  name                       = "eas-backend-secret-santa-email"
  delay_seconds              = 0
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 432000
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.eas_secret_santa_deleted.arn
    maxReceiveCount     = 10
  })
}

resource "aws_sqs_queue" "eas_secret_santa_test" {
  name                       = "eas-backend-secret-santa-email-test"
  delay_seconds              = 0
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 432000
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.eas_secret_santa_deleted.arn
    maxReceiveCount     = 10
  })
}

resource "aws_sqs_queue" "eas_secret_santa_deleted" {
  name                       = "eas-backend-secret-santa-email-deleted"
  delay_seconds              = 0
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 432000
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled = false
}

resource "aws_sqs_queue" "eas_secret_santa_test_deleted" {
  name                       = "eas-backend-secret-santa-email-test-deleted"
  delay_seconds              = 0
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 432000
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled = false
}

# Lambda role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eas_mail_consumer_role" {
  name = "eas-consumer"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eas_mail_consumer_role_sqs_ro" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
  role       = aws_iam_role.eas_mail_consumer_role.name
}

resource "aws_iam_role_policy_attachment" "eas_mail_consumer_role_sqs_exec" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  role       = aws_iam_role.eas_mail_consumer_role.name
}

resource "aws_iam_role_policy_attachment" "eas_mail_consumer_role_lambda_exec" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.eas_mail_consumer_role.name
}

resource "aws_iam_role_policy_attachment" "eas_mail_consumer_role_ses_full" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
  role       = aws_iam_role.eas_mail_consumer_role.name
}

# Lambda function

resource "aws_lambda_function" "eas_email_consumer" {
  filename      = "eas-email-consumer-0.1.0.zip"
  function_name = "eas-email-consumer"
  role          = aws_iam_role.eas_mail_consumer_role.arn
  handler       = "aws_lambda.lambda_handler"
  timeout       = "15"

  source_code_hash = file("eas-email-consumer-0.1.0.sha256")

  environment {
    variables = {
      EAS_WAAPI_TOKEN      = var.eas_waapi_token
      EAS_WHATSAPP_TOKEN   = var.eas_whatsapp_token
    }
  }

  runtime = "python3.9"

}

resource "aws_lambda_function" "eas_email_consumer_test" {
  filename      = "eas-email-consumer-0.2.0.zip"
  function_name = "eas-email-consumer_test"
  role          = aws_iam_role.eas_mail_consumer_role.arn
  handler       = "aws_lambda.lambda_handler"
  timeout       = "15"

  source_code_hash = file("eas-email-consumer-0.2.0.sha256")

  environment {
    variables = {
      EAS_WAAPI_TOKEN      = var.eas_waapi_token
      EAS_WHATSAPP_TOKEN   = var.eas_whatsapp_token
    }
  }

  runtime = "python3.9"

}

resource "aws_lambda_event_source_mapping" "sqs_trigger_lambda" {
  event_source_arn = aws_sqs_queue.eas_secret_santa.arn
  function_name    = aws_lambda_function.eas_email_consumer.function_name
  batch_size        = 10  # Adjust as needed
}

resource "aws_lambda_event_source_mapping" "sqs_test_trigger_lambda" {
  event_source_arn = aws_sqs_queue.eas_secret_santa_test.arn
  function_name    = aws_lambda_function.eas_email_consumer_test.function_name
  batch_size        = 10  # Adjust as needed
}
