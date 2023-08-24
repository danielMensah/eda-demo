module "part1_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "part1"

  source_path  = "${path.root}/.bin/lambdas/part1"
  handler      = "bootstrap"
  package_type = "Zip"
  runtime      = "go1.x"
  timeout      = 180
  memory_size  = 128

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
      ],
      resources = [module.eda_demo_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
    demo_eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["demo_events_part1"]
    }
  }

  publish = true
}

module "part2_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "part2"

  source_path  = "${path.root}/.bin/lambdas/part2"
  handler      = "bootstrap"
  package_type = "Zip"
  runtime      = "go1.x"
  timeout      = 60
  memory_size  = 128

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
      ],
      resources = [module.eda_demo_table.dynamodb_table_arn]
    }
  }

  event_source_mapping = {
    sqs = {
      event_source_arn                   = module.part2_queue.queue_arn
      function_response_types            = ["ReportBatchItemFailures"]
      batch_size                         = 10
      maximum_batching_window_in_seconds = 5
      scaling_config = {
        maximum_concurrency = 2
      }
    }
  }

  allowed_triggers = {
    sqs = {
      service    = "sqs"
      source_arn = module.part2_queue.queue_arn
    }
  }

  attach_policies    = true
  number_of_policies = 1

  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
  ]

  publish = true
}

module "part3_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "part3"

  source_path  = "${path.root}/.bin/lambdas/part3"
  handler      = "bootstrap"
  package_type = "Zip"
  runtime      = "go1.x"
  timeout      = 180
  memory_size  = 128

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
      ],
      resources = [module.eda_demo_table.dynamodb_table_arn]
    }
  }
}