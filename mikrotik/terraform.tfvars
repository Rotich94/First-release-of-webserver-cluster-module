# ============================================================
# terraform.tfvars  –  Fill in your real values before running
# Generated alongside mikrotik_router.tf from 04-05-2026.backup
# ============================================================

# --- Router connection ---
router_url      = "https://192.168.1.1"   # change to your router's IP
router_username = "timothy"
router_password = "gaTeway2030"

# --- LAN ---
lan_network     = "192.168.1.0/24"
lan_gateway     = "192.168.1.1"
dhcp_pool_start = "192.168.4.1"
dhcp_pool_end   = "192.168.15.254"
dns_server      = "8.8.8.8","192.168.55"

# --- Users ---
user_timothy_password = "gaTeway2030"
user_peter_password   = "CHANGE_ME"

# --- P2P tunnel addresses ---
p2p_ruiru_address   = "192.168.88.1"   # fill with actual tunnel endpoint
p2p_mombasa_address = "192.168.22.1"
p2p_mbs_address     = "192.168.22.1"

# --- DST-NAT port-forward targets ---
# zkteco ADMS
zkteco_dst_ip   = "192.168.1.XXX"
zkteco_dst_port = "4370"

# SYSPRO / Remote DT
syspro_dst_ip   = "192.168.1.170"
syspro_dst_port = "80"

# Fusion Hotel system
fusion_dst_ip   = "192.168.0.225"
fusion_dst_port = "6161"

# Fusion B system
fusion_b_dst_ip   = "192.168.0.55"
fusion_b_dst_port = "6162"

# KANGAITA
kangaita_dst_ip   = "192.168.0.55"
kangaita_dst_port = "6162"

# ROBISEARCH OMERON
robisearch_dst_ip   = "192.168.1.XXX"
robisearch_dst_port = "80"

# HRM System (ports 8080 / 8443)
hrm_dst_ip = "192.168.1.XXX"

# Winbox remote
winbox_dst_ip = "192.168.1.XXX"
