output "topic_arn" {
  value = aws_sns_topic.telemetry.arn
}

output "queue_urls" {
  value = { for k, q in aws_sqs_queue.main : k => q.url }
}
