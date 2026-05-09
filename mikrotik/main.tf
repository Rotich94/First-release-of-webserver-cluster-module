###############################################################################
# MikroTik Router – Terraform Configuration
# Generated from: 04-05-2026.backup  (RouterOS 6.49.7 · MikroTik CRS / CCR)
# Provider: terraform-provider-routeros (pavelkr/routeros)
#
# NOTE: The source file is a proprietary RouterOS binary backup.
# IP addresses, passwords, and keys visible in the binary have been
# replaced with variables — fill in terraform.tfvars before applying.
#
# Apply order:
#   terraform init
#   terraform plan -var-file="terraform.tfvars"
#   terraform apply -var-file="terraform.tfvars"
###############################################################################

terraform {
  required_providers {
    routeros = {
      source  = "pavelkr/routeros"
      version = "~> 1.0"
    }
  }
}

###############################################################################
# PROVIDER
###############################################################################

provider "routeros" {
  hosturl  = var.router_url      # e.g. "https://192.168.88.1"
  username = var.router_username # e.g. "admin"
  password = var.router_password
  insecure = true                # set false if you have a valid TLS cert
}

###############################################################################
# VARIABLES
###############################################################################

variable "router_url"      { type = string }
variable "router_username" { type = string; default = "timothy" }
variable "router_password" { type = string; sensitive = true }

variable "wan_interface"   { type = string; default = "ether1" }
variable "lan_interface"   { type = string; default = "ether2" }

variable "lan_network"     { type = string; default = "192.168.1.0/24" }
variable "lan_gateway"     { type = string; default = "192.168.1.1" }
variable "dhcp_pool_start" { type = string; default = "192.168.4.1" }
variable "dhcp_pool_end"   { type = string; default = "192.168.15.254" }
variable "dns_server"      { type = string; default = "8.8.8.8" }

# P2P links (fill with actual addresses)
variable "p2p_ruiru_address"  { type = string; default = "" }
variable "p2p_mombasa_address"{ type = string; default = "" }
variable "p2p_mbs_address"    { type = string; default = "" }

###############################################################################
# SYSTEM IDENTITY
###############################################################################

resource "routeros_system_identity" "main" {
  name = "MikroTik"   # router name as read from backup
}

resource "routeros_system_clock" "main" {
  time_zone_name = "Africa/Nairobi"   # extracted from backup
}

###############################################################################
# USERS
# Passwords extracted from backup are hashed — reset them here.
# The user 'admin' is the built-in default; only extra users are created.
###############################################################################

resource "routeros_system_user" "timothy" {
  name     = "timothy"
  group    = "full"
  password = var.user_timothy_password
}

resource "routeros_system_user" "peter" {
  name     = "peter"
  group    = "read"
  password = var.user_peter_password
}

variable "user_timothy_password" { type = string; sensitive = true }
variable "user_peter_password"   { type = string; sensitive = true }

###############################################################################
# INTERFACES
# Ethernet ports found in backup: ether1–ether13 + P2P tunnels
###############################################################################

resource "routeros_interface_ethernet" "ether1" {
  name    = "ether1"
  comment = "ether1 (JTL) – WAN"
}

resource "routeros_interface_ethernet" "ether2" {
  name    = "ether2"
  comment = "ether2 (LAN)"
}

resource "routeros_interface_ethernet" "ether3"  { name = "ether3"  }
resource "routeros_interface_ethernet" "ether4"  { name = "ether4"  }
resource "routeros_interface_ethernet" "ether5"  { name = "ether5"  }
resource "routeros_interface_ethernet" "ether6"  { name = "ether6"  }
resource "routeros_interface_ethernet" "ether7"  { name = "ether7"  }
resource "routeros_interface_ethernet" "ether8"  { name = "ether8"  }
resource "routeros_interface_ethernet" "ether9"  { name = "ether9"  }
resource "routeros_interface_ethernet" "ether10" { name = "ether10" }
resource "routeros_interface_ethernet" "ether11" { name = "ether11" }
resource "routeros_interface_ethernet" "ether12" { name = "ether12" }
resource "routeros_interface_ethernet" "ether13" { name = "ether13" }

# ---------- P2P EoIP / tunnel interfaces (as found in backup) ----------

resource "routeros_interface_ethernet" "p2p_ruiru" {
  name    = "P2P TO RUIRU"
  comment = "P2P link to Ruiru site"
}

resource "routeros_interface_ethernet" "p2p_mombasa" {
  name    = "internet"
  comment = "Mombasa P2P / internet uplink"
}

resource "routeros_interface_ethernet" "p2p_mbs" {
  name    = "p2p to MBS"
  comment = "P2P link to MBS"
}

###############################################################################
# IP ADDRESSES
###############################################################################

resource "routeros_ip_address" "lan" {
  address   = "${var.lan_gateway}/24"
  interface = routeros_interface_ethernet.ether2.name
  comment   = "LAN gateway – Backmart / MSA network"
}

###############################################################################
# DHCP SERVER
###############################################################################

resource "routeros_ip_pool" "dhcp_pool" {
  name    = "dhcp"
  ranges  = ["${var.dhcp_pool_start}-${var.dhcp_pool_end}"]
  comment = "dhcp1 pool (BackmartDHCP)"
}

resource "routeros_ip_dhcp_server" "dhcp1" {
  name       = "dhcp1"
  interface  = routeros_interface_ethernet.ether2.name
  address_pool = routeros_ip_pool.dhcp_pool.name
  disabled   = false
}

resource "routeros_ip_dhcp_server_network" "lan_network" {
  address    = var.lan_network
  gateway    = var.lan_gateway
  dns_server = var.dns_server
  comment    = "Backmart Network / MSA Network"
}

###############################################################################
# DNS
###############################################################################

resource "routeros_ip_dns" "main" {
  servers            = [var.dns_server, "8.8.4.4"]
  allow_remote_requests = true
}

###############################################################################
# FIREWALL – NAT (source/destination rules extracted from backup)
###############################################################################

# --- Masquerade (srcnat) for LAN → WAN ---
resource "routeros_ip_firewall_nat" "srcnat_lan_wan" {
  chain             = "srcnat"
  out_interface     = routeros_interface_ethernet.ether1.name
  action            = "masquerade"
  comment           = "LAN<>WAN for .4 network"
}

# --- DSTNAT rules (port-forwarding) found in backup ---

resource "routeros_ip_firewall_nat" "dstnat_zkteco" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "zkteco ADMS"
  to_addresses = var.zkteco_dst_ip
  to_ports     = var.zkteco_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_remote_dt_syspro" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "Remote DT /Syspro"
  to_addresses = var.syspro_dst_ip
  to_ports     = var.syspro_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_syspro_ports" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "SYSPRO PORTS"
  to_addresses = var.syspro_dst_ip
  to_ports     = var.syspro_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_fusion_hotel_cph" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "Fusion Hotel system port CPH"
  to_addresses = var.fusion_dst_ip
  to_ports     = var.fusion_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_fusion_hotel_srcnat" {
  chain        = "srcnat"
  protocol     = "tcp"
  action       = "src-nat"
  comment      = "Fusion Hotel System Port Cph"
  to_addresses = var.fusion_dst_ip
}

resource "routeros_ip_firewall_nat" "dstnat_fusion_b_cph" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "Fusion B system CPH"
  to_addresses = var.fusion_b_dst_ip
  to_ports     = var.fusion_b_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_kangaita" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "KANGAITA"
  to_addresses = var.kangaita_dst_ip
  to_ports     = var.kangaita_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_robisearch_omeron" {
  chain        = "dstnat"
  protocol     = "tcp"
  action       = "dst-nat"
  comment      = "ROBISEARCH OMERON SYSTEM"
  to_addresses = var.robisearch_dst_ip
  to_ports     = var.robisearch_dst_port
}

resource "routeros_ip_firewall_nat" "dstnat_hrm_8443" {
  chain        = "dstnat"
  protocol     = "tcp"
  dst_port     = "8443"
  action       = "dst-nat"
  comment      = "PORT 8443 HRM SYSTEM https"
  to_addresses = var.hrm_dst_ip
  to_ports     = "8443"
}

resource "routeros_ip_firewall_nat" "dstnat_hrm_8080" {
  chain        = "dstnat"
  protocol     = "tcp"
  dst_port     = "8080"
  action       = "dst-nat"
  comment      = "PORT 8080 HRM SYSTEM"
  to_addresses = var.hrm_dst_ip
  to_ports     = "8080"
}

resource "routeros_ip_firewall_nat" "dstnat_winbox" {
  chain        = "dstnat"
  protocol     = "tcp"
  dst_port     = "8291"
  action       = "dst-nat"
  comment      = "winbox-3.41 remote access"
  to_addresses = var.winbox_dst_ip
  to_ports     = "8291"
}

# ---------- NAT destination variables ----------

variable "zkteco_dst_ip"      { type = string; default = "" }
variable "zkteco_dst_port"    { type = string; default = "" }
variable "syspro_dst_ip"      { type = string; default = "" }
variable "syspro_dst_port"    { type = string; default = "" }
variable "fusion_dst_ip"      { type = string; default = "" }
variable "fusion_dst_port"    { type = string; default = "" }
variable "fusion_b_dst_ip"    { type = string; default = "" }
variable "fusion_b_dst_port"  { type = string; default = "" }
variable "kangaita_dst_ip"    { type = string; default = "" }
variable "kangaita_dst_port"  { type = string; default = "" }
variable "robisearch_dst_ip"  { type = string; default = "" }
variable "robisearch_dst_port"{ type = string; default = "" }
variable "hrm_dst_ip"         { type = string; default = "" }
variable "winbox_dst_ip"      { type = string; default = "" }

###############################################################################
# FIREWALL – FILTER (input chain, Winbox allow rule found in backup)
###############################################################################

resource "routeros_ip_firewall_filter" "allow_winbox" {
  chain    = "input"
  protocol = "tcp"
  dst_port = "8291"
  action   = "accept"
  comment  = "WINBOX – allow Winbox management access"
}

resource "routeros_ip_firewall_filter" "drop_invalid" {
  chain             = "input"
  connection_state  = "invalid"
  action            = "drop"
  comment           = "Drop invalid connections"
}

resource "routeros_ip_firewall_filter" "accept_established" {
  chain             = "input"
  connection_state  = "established,related"
  action            = "accept"
  comment           = "Accept established/related"
}

###############################################################################
# SERVICES  (as found in backup: www, ftp, ssh, telnet, api, api-ssl, winbox)
###############################################################################

resource "routeros_ip_service" "www" {
  name     = "www"
  port     = 80
  disabled = false
}

resource "routeros_ip_service" "ftp" {
  name     = "ftp"
  port     = 21
  disabled = false
}

resource "routeros_ip_service" "ssh" {
  name     = "ssh"
  port     = 22
  disabled = false
}

resource "routeros_ip_service" "telnet" {
  name     = "telnet"
  port     = 23
  disabled = false
}

resource "routeros_ip_service" "api" {
  name     = "api"
  port     = 8728
  disabled = false
}

resource "routeros_ip_service" "api_ssl" {
  name     = "api-ssl"
  port     = 8729
  disabled = false
}

resource "routeros_ip_service" "winbox" {
  name     = "winbox"
  port     = 8291
  disabled = false
}

###############################################################################
# SNMP
###############################################################################

resource "routeros_snmp" "main" {
  enabled   = true
  trap_version = 2
}

resource "routeros_snmp_community" "public" {
  name      = "public"
  addresses = ["0.0.0.0/0"]
  security  = "none"
}

###############################################################################
# SWITCH (CRS / RB hardware – switch0/switch1 with ether1-10 chip ports)
###############################################################################

resource "routeros_interface_bridge" "bridge_lan" {
  name    = "bridge-lan"
  comment = "LAN bridge"
}

resource "routeros_interface_bridge_port" "ether2_port" {
  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = routeros_interface_ethernet.ether2.name
}

resource "routeros_interface_bridge_port" "ether3_port" {
  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = routeros_interface_ethernet.ether3.name
}

resource "routeros_interface_bridge_port" "ether4_port" {
  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = routeros_interface_ethernet.ether4.name
}

resource "routeros_interface_bridge_port" "ether5_port" {
  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = routeros_interface_ethernet.ether5.name
}

###############################################################################
# LOGGING
###############################################################################

resource "routeros_system_logging" "memory" {
  action  = "memory"
  topics  = "!debug,!snmp"
  comment = "Log to memory"
}

resource "routeros_system_logging" "disk" {
  action  = "disk"
  topics  = "error,warning"
  comment = "Log errors/warnings to disk"
}

###############################################################################
# NTP CLIENT (Africa/Nairobi uses pool.ntp.org)
###############################################################################

resource "routeros_system_ntp_client" "main" {
  enabled  = true
  servers  = ["pool.ntp.org"]
}

###############################################################################
# QUEUE TYPES  (defaults present in backup)
###############################################################################

# Default queue types exist in RouterOS out-of-the-box.
# PCQ queues for upload/download bandwidth management:

resource "routeros_queue_type" "pcq_download" {
  name          = "pcq-download-default"
  kind          = "pcq"
  pcq_rate      = "0"
  pcq_limit     = "50KiB"
  pcq_classifier = ["dst-address"]
  comment       = "PCQ download – restored from backup"
}

resource "routeros_queue_type" "pcq_upload" {
  name          = "pcq-upload-default"
  kind          = "pcq"
  pcq_rate      = "0"
  pcq_limit     = "50KiB"
  pcq_classifier = ["src-address"]
  comment       = "PCQ upload – restored from backup"
}

###############################################################################
# HOTSPOT  (server profile found in backup, using MikroTik default)
###############################################################################

resource "routeros_ip_hotspot_profile" "default" {
  name          = "default"
  hotspot_address = var.lan_gateway
  login_by      = ["http-pap"]
  dns_name      = ""
  html_directory = "hotspot"
}

###############################################################################
# OUTPUTS
###############################################################################

output "router_identity" {
  value = routeros_system_identity.main.name
}

output "lan_gateway" {
  value = routeros_ip_address.lan.address
}

output "dhcp_pool_range" {
  value = routeros_ip_pool.dhcp_pool.ranges
}
