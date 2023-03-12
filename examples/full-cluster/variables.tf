variable "github_user" {
  description = "GitHub username of API user"
  type        = string
  default     = null
}

variable "github_token" {
  description = "GitHub token of API user"
  type        = string
  default     = null
}

variable "github_webhook_secret" {
  description = "Secret used to validate GitHub webhooks (see https://developer.github.com/webhooks/securing/)"
  type        = string
  default     = null
}

variable "github_repo_allow_list" {
  description = "Atlantis requires you to specify an allowlist of repositories it will accept webhooks from"
  type        = string
  default     = null
}
