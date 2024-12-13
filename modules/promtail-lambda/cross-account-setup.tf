resource "aws_cloudwatch_log_destination" "destination" {
  name       = "CrossAccountDestination"
  target_arn = aws_lambda_function.this.arn // PromTail lambda
  role_arn   = aws_iam_role.this.arn
}

resource "aws_cloudwatch_log_destination_policy" "destination_policy" {

  destination_name = aws_cloudwatch_log_destination.destination.name
  access_policy    = data.aws_iam_policy_document.destination_policy.json
}

# Define the IAM Policy Document for the destination
data "aws_iam_policy_document" "destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.monitoring_accounts_id // need to be the origin account id, tried with the Organization but it didn't work
    }

    actions = [
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      aws_cloudwatch_log_destination.destination.arn,
    ]
  }
}