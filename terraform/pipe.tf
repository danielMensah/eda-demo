resource "aws_iam_role" "eda_part3_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "pipes.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }
  })
}

resource "aws_iam_role_policy" "eda_part3_source" {
  role = aws_iam_role.eda_part3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
        ],
        Resource = [
          module.part3_queue.queue_arn,
        ]
      },
    ]
  })

  depends_on = [module.part3_queue]
}

resource "aws_iam_role_policy" "eda_part3_enrichment" {
  role = aws_iam_role.eda_part3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:InvokeApiDestination",
        ],
        Resource = [
          module.eventbridge.eventbridge_api_destination_arns["jsonplaceholder"],
        ]
      },
    ]
  })

  depends_on = [module.eventbridge]
}

resource "aws_iam_role_policy" "eda_part3_target" {
  role = aws_iam_role.eda_part3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ],
        Resource = [
          module.part3_lambda.lambda_function_arn,
        ]
      },
    ]
  })

  depends_on = [module.part3_lambda]
}

resource "aws_pipes_pipe" "eda_part3" {
  name       = "part3"
  role_arn   = aws_iam_role.eda_part3_role.arn
  source     = module.part3_queue.queue_arn
  enrichment = module.eventbridge.eventbridge_api_destination_arns["jsonplaceholder"]
  target     = module.part3_lambda.lambda_function_arn

  source_parameters {
    filter_criteria {
      filter {
        pattern = jsonencode({
          body = {
            detail = {
              type = [{ "prefix" : "text-processing" }]
            }
          }
        })
      }
    }
  }

  target_parameters {
    input_template = <<EOF
{
  "userId" : "<$.userId>",
  "title" : "<$.title>",
  "completed" : "<$.completed>",
  "part" : "Part 3"
}
EOF
  }

  depends_on = [
    aws_iam_role_policy.eda_part3_source,
    aws_iam_role_policy.eda_part3_enrichment,
    aws_iam_role_policy.eda_part3_target,
  ]
}