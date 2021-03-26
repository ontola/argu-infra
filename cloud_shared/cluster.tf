
resource "digitalocean_ssh_key" "archer" {
  name = "archer"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkNoz02B+zy/FEqrsrRMLqMi1OYEWIrl5wl/7g4+TFy fletcher91@fletcher91"
}

resource "digitalocean_ssh_key" "archer_rsa" {
  name = "archer-rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvc6Zl6mht926qrRDmpntpJYznOa1OeD+Z8kd8ARMgixktTODZQaD5vaBB1ORV+UJpZHe4o4GEI6ercUgli8YqAbXktyBPZYgzkU3k6AqO3j0JkHPPJQYQ+CoqiDl8QgsCh56tXClDnr7Rc0LhVKR3QZO6mCLSUeCL8nLb4oZNPd6cUz2djx6BFp+MtWKFs19VLmmviD9iPdhXz2y1bHjYr1Bs0ESdMEuqVNdpFQOEXBJe/fQW5wGtwi/3/VawwRS03tVnDJYAZ+0M9huibGD2wVM8pGtGBu13EyytfZWuQ/J+Ut8gDTKIgBysd12ks15FfXNpNtB+M30swS7UCLSx fletcher91@fletcher91"
}
