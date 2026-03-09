# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/vitalaxis/application"
  retention_in_days = 7
  
  tags = {
    Name        = "vitalaxis-logs"
    Environment = var.environment
  }
}

# IAM policy for CloudWatch logs
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "vitalaxis-cloudwatch-logs"
  description = "Allow EC2 to send logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.app.arn}:*"
      }
    ]
  })
}

# Attach policy to EC2 role
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}
