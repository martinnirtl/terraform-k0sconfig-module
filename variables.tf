variable "name" {
  default = "k0s-cluster"
  type    = string
}

variable "fqdn" {
  type = string
}

variable "controllers" {
  type = list(string)
}

variable "workers" {
  type = list(string)
}

variable "sshkey_path" {
  type = string
}

variable "user" {
  type    = string
  default = "ubuntu"
}

variable "service_account_issuer" {
  type     = string
  nullable = true
}

variable "service_account_jwks_uri" {
  type     = string
  nullable = true
}
