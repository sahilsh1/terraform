data "aws_caller_identity" "current" {}
# code build
resource "aws_codebuild_project" "eternals" {
  name          = "eternals-docker-build"
  description   = "eternals docker build"
  build_timeout = "30"
  service_role  = aws_iam_role.eternals-codebuild.arn
  # encryption_key = aws_kms_alias.eternals-artifacts.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  #cache {
  #  type     = "S3"
  #  location = aws_s3_bucket.codebuild-cache.bucket
  #}

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_REGION
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.eternals.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  #depends_on      = [aws_s3_bucket.codebuild-cache]
}