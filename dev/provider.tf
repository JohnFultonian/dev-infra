variable "do_token" {}
variable "dnsimple_token" {}
variable "dnsimple_account" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

provider "dnsimple" {
  account = "${var.dnsimple_account}"
  token = "${var.dnsimple_token}"
}
