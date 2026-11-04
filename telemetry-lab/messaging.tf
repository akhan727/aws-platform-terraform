locals {
  consumers = toset(["health", "playback"])
}

# One topic every TV event is published to
resource "aws_sns_topic" "telemetry" {
  name = "${var.name_prefix}-telemetry"
}

# Dead-letter queues: where messages go after failing too many times
resource "aws_sqs_queue" "dlq" {
  for_each                  = local.consumers
  name                      = "${var.name_prefix}-${each.key}-dlq"
  message_retention_seconds = 1209600 # 14 days
}

# One main queue per consumer
resource "aws_sqs_queue" "main" {
  for_each                   = local.consumers
  name                       = "${var.name_prefix}-${each.key}"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 20     # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = 5
  })
}

# Queue policy: allow ONLY our SNS topic to send into each queue
data "aws_iam_policy_document" "allow_sns" {
  for_each = local.consumers

  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main[each.key].arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.telemetry.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_sns" {
  for_each  = local.consumers
  queue_url = aws_sqs_queue.main[each.key].id
  policy    = data.aws_iam_policy_document.allow_sns[each.key].json
}

# Subscriptions: each queue only receives its own event type
resource "aws_sns_topic_subscription" "to_queue" {
  for_each             = local.consumers
  topic_arn            = aws_sns_topic.telemetry.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.main[each.key].arn
  raw_message_delivery = true
  filter_policy        = jsonencode({ event_type = [each.key] })
}
