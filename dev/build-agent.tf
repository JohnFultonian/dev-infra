variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "agent_token" {}
variable "bitbucket_rsa" {}

resource "digitalocean_droplet" "build-agent" {
  image = "coreos-stable"
  name = "build-agent"
  region = "sgp1"
  size = "1gb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
    user = "core"
    type = "ssh"
    private_key = "${file("${var.pvt_key}")}"
    timeout = "2m"
  }

  provisioner "file" {
    content = "${var.bitbucket_rsa}"
    destination = "/home/core/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "cd",
      "sudo mkdir /build",
      "sudo chmod a+w /build",
      "docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.ssh:/root/.ssh -v /build:/build -e BUILDKITE_BUILD_PATH='/build' -e BUILDKITE_AGENT_TOKEN='${var.agent_token}' buildkite/agent"
    ]
  }
}
