resource "aws_iam_role" "eternals-codepipeline" {
  name = "eternals-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "eternals-codepipeline-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.eternals-artifacts.arn,
      "${aws_s3_bucket.eternals-artifacts.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eternals-codepipeline",
    ]
  }
  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "kms:DescribeKey",
  #     "kms:GenerateDataKey*",
  #     "kms:Encrypt",
  #     "kms:ReEncrypt*",
  #     "kms:Decrypt",
  #   ]
  #   resources = [
  #     aws_kms_key.eternals-artifacts.arn,
  #   ]
  # }
  statement {
    effect = "Allow"
    actions = [
      "codecommit:UploadArchive",
      "codecommit:Get*",
      "codecommit:BatchGet*",
      "codecommit:Describe*",
      "codecommit:BatchDescribe*",
      "codecommit:GitPull",
    ]
    resources = [
      aws_codecommit_repository.eternals.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*",
      "ecs:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.ecs-task-execution-role.arn,
      aws_iam_role.ecs-eternals-task-role.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "eternals-codepipeline" {
  name   = "codepipeline-policy"
  role   = aws_iam_role.eternals-codepipeline.id
  policy = data.aws_iam_policy_document.eternals-codepipeline-role-policy.json
}