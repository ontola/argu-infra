# Infra

## Setup
- Install the [editor plugin](https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support)

These steps are only needed to communicate with the cloud (other than via the code repository)
- Download [terraform cli](https://www.terraform.io/downloads.html)
- Login (`terraform login`)
- Init (`terraform init`)

## Other
### Utilities
The bin folder contains some scripts to manage infrastructure and execute common tasks.

### Accessing the portal
The portal can be accessed with the following steps
- Forward the apex service: `./bin/service-forward.sh apex`
- Set headers in the browser (eg with modheader)
  - `Authorization: Bearer <staff token>`
  - `X-Forwarded-Host: <argu hostname>`
  - `X-Forwarded-For: 10.244.0.255`
- Go to `http://localhost:30000/argu/portal/sidekiq`
