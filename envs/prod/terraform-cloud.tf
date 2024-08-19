#terraform-cloud.tf
terraform {
  cloud {
    organization = "cwave-druwa"

    workspaces {
      name = "terraform"
    }
  }
}