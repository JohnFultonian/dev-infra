variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "agent_token" {}

resource "digitalocean_droplet" "build-agent" {
  image = "coreos-stable"
  name = "build-agent"
  region = "nyc2"
  size = "1gb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]


  provisioner "remote-exec" {
    inline = [
      "docker run -d -e BUILDKITE_AGENT_TOKEN='${var.agent_token}' buildkite/agent"
    ]

    connection {
      user = "core"
      type = "ssh"
      private_key = "${file("${var.pvt_key}")}"
      timeout = "2m"
    }
  }
}
