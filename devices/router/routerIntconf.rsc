# 2025-11-14 18:04:30 by RouterOS 7.13.5
# software id = WDCW-PNZP
#
# model = CCR2004-16G-2S+
# serial number = HGA09ZBSP3T
/interface bridge
add name=Bridge-VLAN20
add name=Bridge_Acceso_General
add comment="Bridge between ether15 and ether16" name=bridge-15-16
add fast-forward=no name=loopback
add name=zabbix
/interface ethernet
set [ find default-name=ether1 ] name=CISCO_SWITCH
set [ find default-name=ether2 ] name=ROUTER_ONE
/interface eoip
add mac-address=02:03:DE:ED:2B:C0 name=eoip-tunnel1 remote-address=\
    10.10.177.100 tunnel-id=55
/interface vlan
add interface=CISCO_SWITCH name=vlan10-Gestion vlan-id=10
add interface=CISCO_SWITCH name=vlan20-Core vlan-id=20
add interface=CISCO_SWITCH name=vlan30-Monitoreo vlan-id=30
add interface=CISCO_SWITCH name=vlan40-Servicios vlan-id=40
add interface=CISCO_SWITCH name=vlan50-Web vlan-id=50
add interface=CISCO_SWITCH name=vlan100-GPON vlan-id=100
/port
set 0 name=serial0
set 1 name=serial1
/snmp community
add addresses=192.168.0.0/16 name=gponRouter
add addresses=192.168.173.0/24 name=librenms
add addresses=192.168.173.0/24 name=nms
/interface bridge port
add bridge=bridge-15-16 interface=ether15
add bridge=bridge-15-16 interface=ether16
add bridge=Bridge-VLAN20 interface=ether14
add bridge=Bridge-VLAN20 interface=vlan20-Core
/ip address
add address=192.168.10.1/24 interface=vlan10-Gestion network=192.168.10.0
add address=192.168.20.1/24 interface=vlan20-Core network=192.168.20.0
add address=192.168.30.1/24 interface=vlan30-Monitoreo network=192.168.30.0
add address=192.168.40.1/24 interface=vlan40-Servicios network=192.168.40.0
add address=192.168.50.1/24 interface=vlan50-Web network=192.168.50.0
add address=192.168.100.1/24 interface=vlan100-GPON network=192.168.100.0
add address=192.168.88.142/24 interface=ROUTER_ONE network=192.168.88.0
add address=192.168.173.1/24 comment="Gateway for Pi+Mac" interface=\
    bridge-15-16 network=192.168.173.0
/ip dhcp-client
add interface=ROUTER_ONE
/ip dhcp-relay
add dhcp-server=192.168.20.2 disabled=no interface=vlan100-GPON \
    local-address=192.168.100.1 name=DHCP-VLAN100
/ip firewall address-list
add address=192.168.0.0/16 list=internas
add address=192.168.10.0/24 comment="VLAN 10 -Gestion" list=admin
add address=192.168.73.0/24 comment="Bridge 15-16" list=admin
add address=192.168.20.20 comment="DNS Primary" list=dns-servers
add address=192.168.20.21 comment="DNS Secondary" list=dns-servers
add address=192.168.20.2 comment="Kea DHCP" list=dhcp-servers
add address=192.168.20.60 comment="Chrony NTP" list=ntp-servers
add address=192.168.50.10 comment="Caddy Web 1" list=web-servers
add address=192.168.50.11 comment="Caddy Web 2" list=web-servers
add address=192.168.50.20 comment="Reverse Proxy" list=web-servers
add address=192.168.40.50 comment=Dovecot/Postfix list=mail-servers
/ip firewall filter
add action=accept chain=forward dst-address=192.168.50.20 dst-port=443 \
    protocol=udp
add action=accept chain=input comment="01-INPUT: Accept stablished/related" \
    connection-state=established,related
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ROUTER_ONE src-address=\
    192.168.0.0/16
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.88.1
/ipv6 route
add blackhole comment="IPv6 solo interno" dst-address=::/0
/ipv6 address
add address=2001:db8:10::1 interface=vlan10-Gestion
add address=2001:db8:20::1 interface=vlan20-Core
add address=2001:db8:30::1 interface=vlan30-Monitoreo
add address=2001:db8:40::1 interface=vlan40-Servicios
add address=2001:db8:50::1 interface=vlan50-Web
add address=2001:db8:100::1 interface=vlan100-GPON
/ipv6 nd
add dns=2001:db8:20::20 interface=vlan100-GPON ra-interval=20s-1m
add dns=2001:db8:20::20 interface=vlan10-Gestion ra-interval=20s-1m
add dns=2001:db8:20::20 interface=vlan20-Core ra-interval=20s-1m
add dns=2001:db8:20::20 interface=vlan30-Monitoreo ra-interval=20s-1m
add dns=2001:db8:20::20 interface=vlan40-Servicios ra-interval=20s-1m
add dns=2001:db8:20::20 interface=vlan50-Web ra-interval=20s-1m
/snmp
set contact="X <x>" enabled=yes location=\
    X
/system clock
set time-zone-name=America/Bogota
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=192.168.20.60
/system routerboard settings
set enter-setup-on=delete-key
