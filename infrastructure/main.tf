provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource aws_iam_role mix_ingredients_role {
  name = "mix_ingredients_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


resource aws_lambda_function mix_ingredients {
  filename      = "../build/mixIngredients.zip"
  function_name = "mix_ingredients_lambda"
  role          = aws_iam_role.mix_ingredients_role.arn
  handler       = "provision"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../build/mixIngredients.zip")

  runtime     = "go1.x"
  memory_size = 128
  timeout     = 60
}


resource aws_iam_role bake_holiday_cookies_role {
  name = "bake_holiday_cookies_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource aws_iam_role_policy bake_holiday_cookies_policy {
  name = "bake_holiday_cookies_policy"
  role = aws_iam_role.bake_holiday_cookies_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Effect": "Allow",
      "Action": [
          "lambda:InvokeFunction"
      ],
      "Resource": [
          "*"
      ]
    }
  ]
}
EOF

}

resource "aws_sfn_state_machine" "bake_holiday_cookies" {
  name     = "bake_holiday_cookies"
  role_arn = "${aws_iam_role.bake_holiday_cookies_role.arn}"

  definition = <<EOF
{
  "Comment": "A state machine to bake and decorate delicious holiday cookies",
  "StartAt": "PrepKitchen",
  "States": {
    "PrepKitchen": {
      "Type": "Pass",
      "Result": ["flour", "baking powder", "salt", "butter", "sugar", "egg", "vanilla extract", "almond extract"],
      "Next": "MixIngredients"
    },
    "MixIngredients": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.mix_ingredients.arn}",
      "Next": "ChillDough"
    },
    "ChillDough": {
      "Type": "Wait",
      "Seconds": 7200,
      "Next": "EatDoughOrBakeDough"
    }, 
    "EatDoughOrBakeDough": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.eatDough",
          "BooleanEquals": true,
          "Next": "EatDough"
        },
        {
          "Variable": "$.eatDough",
          "BooleanEquals": false,
          "Next": "RollOutDoughAndCutOutShapes"
        }
      ]
    },
    "EatDough": {
      "Type": "Pass",
      "Result": "empty bowl",
      "End": true
    },
    "RollOutDoughAndCutOutShapes": {
      "Type": "Pass",
      "Result": "Hello World!",
      "Next": "Bake"
    },
    "Bake": {
      "Type": "Pass",
      "Result": "Hello World!",
      "Next": "WaitForGoldenEdges"
    },
    "WaitForGoldenEdges": {
      "Type": "Wait",
      "Seconds": 60,
      "Next": "Golden?"
    },
    "Golden?": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.golden",
          "BooleanEquals": true,
          "Next": "CoolCookies"
        }
      ],
      "Default": "WaitForGoldenEdges"
    },
    "CoolCookies": {
      "Type": "Pass",
      "Result": "Hello World!",
      "Next": "DecorateCookies"
    },
    "DecorateCookies": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF
}
