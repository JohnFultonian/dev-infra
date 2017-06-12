variable "registry_gcs_token" {}
variable "registry_htpasswd" {}
variable "registry_subdomain" {default="hub"}
variable "domain" {}
variable "email" {}

resource "digitalocean_droplet" "docker_registry" {
  image = "coreos-stable"
  name = "docker-registry"
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
    content = <<EOF
DOMAIN=${var.registry_subdomain}.${var.domain}
EMAIL=${var.email}
EOF
    destination = "/home/core/certbot-env"
  }

  provisioner "file" {
    content = "${var.registry_gcs_token}"
    destination = "/home/core/gcs-key.json"
  }

  provisioner "file" {
    content = "${var.registry_htpasswd}"
    destination = "/home/core/htpasswd"
  }

  provisioner "file" {
    source = "scripts/certbot.sh"
    destination = "/home/core/certbot.sh"
  }

  provisioner "file" {
    source = "scripts/registry.sh"
    destination = "/home/core/registry.sh"
  }

  provisioner "file" {
    source = "services/certbot.service"
    destination = "/tmp/certbot.service"
  }
  
  provisioner "file" {
    source = "services/certbot.timer"
    destination = "/tmp/certbot.timer"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/core",
      "chmod +x registry.sh",
      "chmod +x certbot.sh",
      "sed -i \"s/'//g\" gcs-key.json",
      "sudo mv /tmp/certbot.{service,timer} /etc/systemd/system/",
      "sudo systemctl start certbot.timer",
      "./registry.sh ${var.registry_subdomain}.${var.domain}",
    ]
  }

}

resource "dnsimple_record" "hub" {
  domain = "${var.domain}"
  name = "${var.registry_subdomain}"
  type = "A"
  value = "${digitalocean_droplet.docker_registry.ipv4_address}"
  ttl = 60
}
