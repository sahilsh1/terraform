# resource "aws_codecommit_repository" "eternalsCodeCommit" {
#   repository_name = "eternalsRepo"
#   description     = "This is the eternals  repository"
# }
resource "aws_codecommit_repository" "eternals" {
  repository_name = "eternals"
  description     = "This is the eternals repository"
  default_branch  = "master"
  
}
