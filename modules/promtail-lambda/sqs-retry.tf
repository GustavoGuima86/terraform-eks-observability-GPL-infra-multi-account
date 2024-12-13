locals {
  main_queue = "main-retry-queue"
  dlq_queue  = "dlq-retry-queue"
}

resource "aws_sqs_queue" "main_queue" {
  name                       = local.main_queue
  sqs_managed_sse_enabled    = true
  policy                     = data.aws_iam_policy_document.queue_policy_retry.json
  visibility_timeout_seconds = 650
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.retry_dead_letter.arn
    maxReceiveCount     = 5
  })
}

data "aws_iam_policy_document" "queue_policy_retry" {
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage"
    ]

    resources = ["arn:aws:sqs:*:*:${local.main_queue}"]

    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }

    # Condition to ensure messages are re-driven only from allowed DLQ sources
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sqs_queue.retry_dead_letter.arn]
    }
  }
}

resource "aws_sqs_queue" "retry_dead_letter" {
  name                    = local.dlq_queue
  sqs_managed_sse_enabled = true
}

# IAM Policy for Lambda Execution Role to write in sqs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy-retry"
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.retry_dead_letter.arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_origin" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.this.arn
}

data "aws_iam_policy" "lambda_sqs_execution_policy" {
  name = "AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_execution_policy" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.lambda_sqs_execution_policy.arn
}


resource "aws_sns_topic" "sns_alert_topic" {
  name = "alert-DLQ-logs-queue"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_alert_topic.arn
  protocol  = "email"
  endpoint  = var.email_alert
}

# CloudWatch Alarm for SQS queue
resource "aws_cloudwatch_metric_alarm" "sqs_queue_alarm" {
  alarm_name          = "${aws_sqs_queue.retry_dead_letter.name}-QueueAlarm"
  alarm_description   = "Triggered when the SQS queue has one or more messages."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    QueueName = aws_sqs_queue.retry_dead_letter.name
  }

  alarm_actions = [aws_sns_topic.sns_alert_topic.arn]
}