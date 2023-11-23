terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.25.1"
    }
  }
}

variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}


# SSH keys
resource "hcloud_ssh_key" "pedro-key" {
  name = "Pedro"
  public_key = file("../roles/users/files/public_keys/pedro")
}

resource "hcloud_ssh_key" "david-key" {
  name = "David"
  public_key = file("../roles/users/files/public_keys/david")
}

resource "hcloud_ssh_key" "mario-key" {
  name = "Mario"
  public_key = file("../roles/users/files/public_keys/mario")
}

# Network
resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server" "het-prod1" {
  name        = "prod-het1"
  server_type = "cpx21"
  image       = "ubuntu-20.04"
  location    = "nbg1"

  network {
      network_id = hcloud_network.network.id
      ip         = "10.0.1.5"
      alias_ips  = [
        "10.0.1.6",
        "10.0.1.7"
      ]
  }

  labels = {
    "environment": "prod"
  }

  ssh_keys = [
    hcloud_ssh_key.mario-key.id,
    hcloud_ssh_key.pedro-key.id,
    hcloud_ssh_key.david-key.id
  ]

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}
