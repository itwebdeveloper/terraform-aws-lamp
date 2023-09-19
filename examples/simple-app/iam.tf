resource "aws_iam_role" "cloudwatch_agent_server_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  description = "Allows EC2 instances to call AWS services on your behalf."
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
  name = "CloudWatchAgentServerRole"
  tags = {
    "Owner" = var.application_owner
    "Team"  = "Engineering"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "cloudwatch_agent_server_role" {
  name = "CloudWatchAgentServerRole"
  role = aws_iam_role.cloudwatch_agent_server_role.name
}