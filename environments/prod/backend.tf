terraform {
  backend "gcs" {
    bucket = "nbp-devops-prod-tfstate"
    prefix = "prod"
  }
}