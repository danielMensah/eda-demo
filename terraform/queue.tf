module "part2_queue" {
  source = "terraform-aws-modules/sqs/aws"

  name                       = "eda-part2"
  visibility_timeout_seconds = 180
  message_retention_seconds  = 600
  delay_seconds              = 5
  create_dlq                 = true
  dlq_name                   = "eda-part2-dlq"
  redrive_policy = {
    maxReceiveCount = 5
  }

  create_queue_policy = true
  queue_policy_statements = {
    events = {
      sid     = "EventBusEvents"
      actions = ["sqs:SendMessage"]
      principals = [
        {
          type        = "Service"
          identifiers = ["events.amazonaws.com"]
        }
      ]
    }
  }
}

module "part3_queue" {
  source = "terraform-aws-modules/sqs/aws"

  name                       = "eda-part3"
  visibility_timeout_seconds = 10
  message_retention_seconds  = 600
  delay_seconds              = 5
  create_dlq                 = true
  dlq_name                   = "eda-part3-dlq"
  redrive_policy = {
    maxReceiveCount = 5
  }

  create_queue_policy = true
  queue_policy_statements = {
    events = {
      sid     = "EventBusEvents"
      actions = ["sqs:SendMessage"]
      principals = [
        {
          type        = "Service"
          identifiers = ["events.amazonaws.com"]
        }
      ]
    }
  }
}