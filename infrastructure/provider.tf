terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "omaralqinneh-resume-bucket-eu"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Project     = "cloud-resume-challenge"
      ManagedBy   = "Terraform"
      Environment = "Production"
      Owner       = "OmarAlqinneh"
    }
  }
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "cloud-resume-challenge"
      ManagedBy   = "Terraform"
      Environment = "Production"
      Owner       = "OmarAlqinneh"
    }
  }
}