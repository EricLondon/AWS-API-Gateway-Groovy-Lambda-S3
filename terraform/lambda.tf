resource "aws_lambda_function" "api_gateway" {
  function_name    = "lambda_api_gateway"
  filename         = "${path.module}/../build/distributions/api-gateway-1.0-SNAPSHOT.zip"
  handler          = "ericlondon.LambdaApiGateway::handler"
  runtime          = "java8"
  source_code_hash = "${base64sha256(file("${path.module}/../build/distributions/api-gateway-1.0-SNAPSHOT.zip"))}"
  role             = "${aws_iam_role.lambda_api_gateway.arn}"
  memory_size      = "512"
  timeout          = "60"

  environment {
    variables = {
      AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
      INFRASTRUCTURE = "${var.infrastructure}"
      INSTANCE_NAME  = "${var.instance_name}"
    }
  }

  tags {
    infrastructure = "${var.infrastructure}"
    instance_name  = "${var.instance_name}"
  }
}

resource "aws_iam_role" "lambda_api_gateway" {
  name = "lambda_api_gateway"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_api_gateway.json}"
}

data "aws_iam_policy_document" "lambda_api_gateway" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_api_gateway_attach_policy" {
  role = "${aws_iam_role.lambda_api_gateway.name}"
  policy_arn = "${aws_iam_policy.lambda_api_gateway_policy.arn}"
}

resource "aws_iam_policy" "lambda_api_gateway_policy" {
  name   = "lambda_api_gateway_policy"
  policy = "${data.aws_iam_policy_document.lambda_api_gateway_policy_document.json}"
}

data "aws_iam_policy_document" "lambda_api_gateway_policy_document" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.api_gateway.function_name}:*"
    ]
  }

 statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api_gateway.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.lambda_api_gateway.execution_arn}/*/*"
}
