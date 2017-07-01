variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "agent_token" {}
variable "bitbucket_rsa" {}
variable "docker_config" {}

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

  provisioner "file" {
    content="${var.docker_config}"
    destination = "/home/core/config.json"
  }

  provisioner "remote-exec" {
    inline = [
      "cd",
      "mkdir -p /home/core/.docker",
      "mv config.json .docker/",
      "sudo mkdir /build",
      "sudo chmod a+w /build",
      "sed -i \"s/'//g\" /home/core/.docker/config.json",
      "docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.docker:/root/.docker -v $HOME/.ssh:/root/.ssh -v /build:/build -e BUILDKITE_BUILD_PATH='/build' -e BUILDKITE_AGENT_TOKEN='${var.agent_token}' buildkite/agent"
    ]
  }
}
