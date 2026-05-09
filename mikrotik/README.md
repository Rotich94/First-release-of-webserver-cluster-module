# MikroTik Router – Terraform Configuration

Terraform configuration for managing a MikroTik RouterOS device using the [pavelkr/routeros](https://registry.terraform.io/providers/pavelkr/routeros/latest) provider. Generated from a RouterOS 6.49.7 binary backup (MikroTik CRS/CCR).

---

## What This Configures

| Category | Details |
|---|---|
| System | Router identity, timezone (Africa/Nairobi), NTP (pool.ntp.org) |
| Users | `timothy` (full access), `peter` (read-only) |
| Interfaces | ether1–ether13, P2P links (Ruiru, Mombasa, MBS) |
| IP / DHCP | LAN gateway, DHCP pool, DNS servers |
| Firewall NAT | Masquerade (LAN→WAN), DST-NAT port forwards (ZKTeco, Syspro, Fusion Hotel, HRM, Winbox, Kangaita, Robisearch) |
| Firewall Filter | Allow Winbox (8291), drop invalid, accept established/related |
| Services | www (80), ftp (21), ssh (22), telnet (23), api (8728), api-ssl (8729), winbox (8291) |
| Bridge | `bridge-lan` with ether2–ether5 ports |
| QoS | PCQ upload/download queue types |
| Hotspot | Default hotspot profile |
| SNMP | Enabled, trap version 2, public community |
| Logging | Memory (all except debug/snmp), disk (errors/warnings) |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- MikroTik router with REST API enabled (`/ip service enable api-ssl`)
- Network access to the router from the machine running Terraform

---

## Project Structure

```
mikrotik/
├── main.tf             # All resources and variables
└── terraform.tfvars    # Your actual values (never commit this)
```

---

## Quick Start

**1. Clone the repo**
```bash
git clone <your-repo-url>
cd mikrotik
```

**2. Fill in your values in `terraform.tfvars`**
```hcl
router_url      = "https://192.168.1.1"
router_username = "timothy"
router_password = "<your-password>"

lan_network     = "192.168.1.0/24"
lan_gateway     = "192.168.1.1"
dhcp_pool_start = "192.168.4.1"
dhcp_pool_end   = "192.168.15.254"
dns_server      = "8.8.8.8"

user_timothy_password = "<password>"
user_peter_password   = "<password>"

# DST-NAT targets
zkteco_dst_ip     = "192.168.1.X"
zkteco_dst_port   = "4370"
syspro_dst_ip     = "192.168.1.170"
syspro_dst_port   = "80"
# ... (see terraform.tfvars for full list)
```

**3. Initialise and apply**
```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Variables Reference

### Router Connection

| Variable | Description | Default |
|---|---|---|
| `router_url` | Router REST API URL (e.g. `https://192.168.1.1`) | — |
| `router_username` | Router admin username | `timothy` |
| `router_password` | Router admin password *(sensitive)* | — |

### Network

| Variable | Description | Default |
|---|---|---|
| `wan_interface` | WAN interface name | `ether1` |
| `lan_interface` | LAN interface name | `ether2` |
| `lan_network` | LAN subnet CIDR | `192.168.1.0/24` |
| `lan_gateway` | LAN gateway IP | `192.168.1.1` |
| `dhcp_pool_start` | DHCP pool start address | `192.168.4.1` |
| `dhcp_pool_end` | DHCP pool end address | `192.168.15.254` |
| `dns_server` | Primary DNS server | `8.8.8.8` |

### DST-NAT Port Forwards

| Variable | Description |
|---|---|
| `zkteco_dst_ip` / `zkteco_dst_port` | ZKTeco ADMS biometric system |
| `syspro_dst_ip` / `syspro_dst_port` | Syspro ERP / Remote DT |
| `fusion_dst_ip` / `fusion_dst_port` | Fusion Hotel system (CPH) |
| `fusion_b_dst_ip` / `fusion_b_dst_port` | Fusion B system (CPH) |
| `kangaita_dst_ip` / `kangaita_dst_port` | Kangaita system |
| `robisearch_dst_ip` / `robisearch_dst_port` | Robisearch Omeron system |
| `hrm_dst_ip` | HRM system (ports 8080 / 8443) |
| `winbox_dst_ip` | Winbox remote access (port 8291) |

---

## Outputs

| Output | Description |
|---|---|
| `router_identity` | Router hostname |
| `lan_gateway` | Configured LAN gateway address |
| `dhcp_pool_range` | DHCP pool range |

---

## Security Notes

- `terraform.tfvars` contains passwords and internal IPs — **never commit it to version control**
- Add `terraform.tfvars` and `*.tfstate*` to your `.gitignore`
- Consider disabling unused services (telnet, ftp) in production
- The `insecure = true` provider setting skips TLS verification — replace with a valid certificate in production

```gitignore
# .gitignore
terraform.tfvars
*.tfstate
*.tfstate.backup
.terraform/
```

---

## Provider

[pavelkr/routeros](https://registry.terraform.io/providers/pavelkr/routeros/latest) `~> 1.0`
