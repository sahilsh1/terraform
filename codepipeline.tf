#
# codepipeline - eternals
#
resource "aws_codepipeline" "eternals" {
  name     = "eternals-docker-pipeline"
  role_arn = aws_iam_role.eternals-codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.eternals-artifacts.bucket
    type     = "S3"
    # encryption_key {
    #   id   = aws_kms_alias.eternals-artifacts.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["eternals-docker-source"]

      configuration = {
        RepositoryName = aws_codecommit_repository.eternals.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["eternals-docker-source"]
      output_artifacts = ["eternals-docker-build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.eternals.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["eternals-docker-build"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.eternals.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.eternals.deployment_group_name
        TaskDefinitionTemplateArtifact = "eternals-docker-build"
        AppSpecTemplateArtifact        = "eternals-docker-build"
      }
    }
  }
}