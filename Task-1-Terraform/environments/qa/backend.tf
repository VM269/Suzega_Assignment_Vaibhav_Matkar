terraform {
  backend "gcs" {
    bucket = "flowvelly-healthcare-tfstate"
    prefix = "service-project/qa"
  }
}
