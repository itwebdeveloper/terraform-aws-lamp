variable "application_owner" {
  description = "Full name of the owner of the application, useful for billing"
  type = string
}

variable "application_owner_email" {
  description = "Email of the owner of the application, useful for billing identification"
  type = string
}

variable "key_pair_key_name" {
  description = "Name of the Key pair"
  type        = string
  default     = ""
}

variable "key_pair_public_key" {
  description = "Public key included in the Key pair"
  type        = string
  default     = ""
}