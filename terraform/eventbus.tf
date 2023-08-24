module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "eda_demo"

  rules = {
    demo_events_part1 = {
      description = "Captures demo part 1 events from apigateway"
      event_pattern = jsonencode({
        "source" : ["demo.apigateway.part1"],
        "detail-type" : ["Part 1"],
        "detail" : {
          "type" : [
            { "prefix" : "video-processing" }
          ]
        }
      })
      enabled = true
    },
    demo_events_part2 = {
      description = "Captures demo part 2 events from apigateway"
      event_pattern = jsonencode({
        "source" : ["demo.apigateway.part2"],
        "detail-type" : ["Part 2"],
        "detail" : {
          "type" : [
            { "prefix" : "audio-processing" }
          ]
        }
      })
      enabled = true
    },
    demo_events_part3 = {
      description = "Captures demo part 3 events from apigateway"
      event_pattern = jsonencode({
        "source" : ["demo.apigateway.part3"],
        "detail-type" : ["Part 3"]
      })
      enabled = true
    }
  }

  targets = {
    demo_events_part1 = [
      {
        name = "part1_lambda"
        arn  = module.part1_lambda.lambda_function_arn
      }
    ],
    demo_events_part2 = [
      {
        name            = "eda_part2_queue"
        arn             = module.part2_queue.queue_arn
        dead_letter_arn = module.part2_queue.dead_letter_queue_arn
      }
    ],
    demo_events_part3 = [
      {
        name            = "eda_part3_queue"
        arn             = module.part3_queue.queue_arn
        dead_letter_arn = module.part3_queue.dead_letter_queue_arn
      }
    ]
  }

  create_connections = true
  connections = {
    jsonplaceholder : {
      authorization_type = "API_KEY"
      auth_parameters = {
        api_key = {
          key   = "x-signature-id"
          value = "dummy-signature"
        }
      }
    }
  }

  create_api_destinations       = true
  attach_api_destination_policy = true
  api_destinations = {
    jsonplaceholder = {
      description                      = "todos endpoint"
      invocation_endpoint              = "https://jsonplaceholder.typicode.com/todos/1"
      http_method                      = "GET"
      invocation_rate_limit_per_second = 10
    }
  }

  attach_sqs_policy = true
  sqs_target_arns = [
    module.part2_queue.queue_arn,
    module.part3_queue.queue_arn
  ]

  attach_lambda_policy = true
  lambda_target_arns = [
    module.part1_lambda.lambda_function_arn
  ]
}