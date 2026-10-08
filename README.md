# Proyecto ISP - Infraestructura GPON

##  Descripción General
Implementación de una red GPON (Gigabit Passive Optical Network) diseñada para un entorno académico, integrando dispositivos físicos de networking y servicios virtualizados sobre Ubuntu Server. 

El proyecto simula un ISP real, abarcando desde la segmentación de red mediante VLANs y servicios core (DNS, DHCP, NTP), hasta el monitoreo avanzado (Observabilidad), calidad de servicio (QoS) y la provisión de "Última Milla" a clientes finales mediante fibra óptica con soporte dual-stack IPv4/IPv6.

##  Equipo de Implementación

Este proyecto fue desarrollado colaborativamente, dividiendo la infraestructura en dominios de responsabilidad técnica especializados.

| Integrante | Rol / Dominio Técnico | Responsabilidades Clave | GitHub |
| :--- | :--- | :--- | :---: |
| **Juan Camilo Melo López** | **Infraestructura de Red & Web** | Configuración de Routing/Switching (MikroTik, Cisco) y despliegue de Servidores Web/Proxy (Caddy). | [`@Melo088`](https://github.com/Melo088) |
| **Angela Camila Quitiaquez Diaz** | **QoS & Gestión de Red** | Implementación de calidad de servicio (LibreQoS) y monitoreo de infraestructura física (LibreNMS). | [`@Angdicode`](https://github.com/Angdicode) |
| **Juan David Pacheco** | **Servicios Core & Observabilidad** | Servicios críticos de red (DHCP, DNS) y stack de métricas visuales (Prometheus, Grafana). | [`@Juanda-2880`](https://github.com/Juanda-2880) |
| **Esteban Guarin Valencia** | **Servicios de Aplicación** | Sincronización de tiempo precisa (NTP) e infraestructura de correo electrónico seguro (SMTP/IMAP). | [`@Esteban-GV`](https://github.com/Esteban-GV) |

---

##  Topología de Red

![Diagrama de Topología](https://i.imgur.com/I5o7OSE.jpg)

### Dispositivos Físicos

| Dispositivo | Modelo | Función |
|-------------|--------|---------|
| **Router Externo** | MikroTik RB3011UiAS-RM | Gateway de borde / Conexión a Internet |
| **Router Interno** | MikroTik CCR2004-16G-2S+PC | Core del ISP, Inter-VLAN routing |
| **Switch** | Cisco SG350X-24 | Distribución Layer 2/3 con soporte VLAN/trunk |
| **OLT** | Huawei EA5800-X2 | Cabecera de red GPON |
| **ONT** | Huawei EchoLife EG8145V5 | Terminal óptico de cliente final |
| **Splitter** | FiberHome Celcia | Divisor óptico pasivo |
| **Servidor** | Laptop Ubuntu Server 24.04 | Host de virtualización de servicios |

### Conexiones Físicas Clave

* **Router Externo (eth8)** → MinisForum Venus LAN2 (QoS Bridge)
* **Router Externo** → **Router Interno (eth1)**
* **Router Interno (eth2)** → **Switch (G1/0/2)**
* **Router Interno (eth14)** → MinisForum Venus LAN1 (QoS Bridge)
* **Switch (G1/0/1)** → **OLT**
* **Switch (G1/0/10)** → **Servidor (Virtualización)**
* **OLT** → **Splitter** → **ONTs** (Fibra óptica)

---

##  Segmentación de Red - VLANs

| VLAN | Nombre | Subred IPv4 | Subred IPv6 | Propósito |
|:---:|---|---|---|---|
| **10** | Gestión | `192.168.10.0/24` | `2001:db8:10::/64` | Administración de dispositivos de red |
| **20** | Servicios_Core | `192.168.20.0/24` | `2001:db8:20::/64` | DHCP, DNS, NTP, Prometheus, Grafana, LibreNMS |
| **40** | Email | `192.168.40.0/24` | `2001:db8:40::/64` | Servidores de Correo (Postfix/Dovecot) |
| **50** | Web | `192.168.50.0/24` | `2001:db8:50::/64` | Caddy Web Server y Reverse Proxy |
| **100** | Clientes_GPON | `192.168.100.0/24` | `2001:db8:100::/64` | Red de Clientes Finales (ONTs) |

---

## Servicios Virtualizados

Los servicios están containerizados o virtualizados sobre **Ubuntu Server 24.04**, garantizando aislamiento y escalabilidad con direccionamiento dual-stack.

![Arquitectura de Servicios](https://i.imgur.com/iBXDZ4Q.jpg)

###  VLAN 20 - Servicios Core & Observabilidad

* **Kea DHCP:** Motor de asignación dinámica de direcciones de alto rendimiento para la VLAN de clientes (100).
* **BIND9 DNS:** Resolución de nombres autoritativa y recursiva con arquitectura redundante (Master/Slave).
* **Chrony NTP:** Servidor de tiempo Stratum local. Fundamental para la coherencia de logs y la seguridad (Kerberos/TLS).
* **Prometheus:** Base de datos de series temporales que recolecta métricas de salud de toda la infraestructura mediante exporters.
* **Grafana:** Visualización de datos en tiempo real. Dashboards personalizados para monitorear tráfico, consumo de CPU y latencia de red.
* **LibreNMS:** Sistema de monitoreo basado en SNMP para el hardware de red (Routers, Switches, OLT), proporcionando mapas de topología y alertas.
* **LibreQoS:** Gestión de ancho de banda (Shaping/Policing) y priorización de tráfico para garantizar la experiencia de usuario (QoE) en la red GPON.

###  VLAN 40 - Infraestructura de Correo

| Servicio | IPv4 | IPv6 | Puertos | Función |
|---|---|---|---|---|
| **Dovecot** | `192.168.40.50` | `2001:db8:40::50` | 143/993, 110/995 | Servidor IMAP/POP3 (Recepción) |
| **Postfix** | `192.168.40.50` | `2001:db8:40::50` | 25, 587, 465 | MTA - Servidor SMTP (Envío) |

* **Postfix:** Configurado como MTA con soporte TLS/SSL para envío seguro y relay de correos.
* **Dovecot:** Permite a los usuarios acceder a sus buzones de forma segura, sincronizando mensajes entre dispositivos.

###  VLAN 50 - Web & Proxy

* **Caddy Web Servers:** Alojamiento de aplicaciones y contenido estático del ISP.
* **Caddy Reverse Proxy:** Gateway único de entrada que distribuye el tráfico hacia los backends, gestionando automáticamente certificados SSL/HTTPS y balanceo de carga.

---

##  Red GPON (VLAN 100)

### Arquitectura de Acceso
La "Última Milla" utiliza fibra óptica pasiva. La OLT **Huawei EA5800-X2** gestiona el tráfico descendente y ascendente hacia las ONTs. El enrutamiento hacia Internet y otras VLANs lo gestiona el **MikroTik CCR2004**.

### Datos de Conexión Clientes
* **Protocolo:** IPv4 & IPv6 (Dual Stack)
* **Rango IPv4:** `192.168.100.100` - `192.168.100.200`
* **Gateway:** `192.168.100.1`
* **DNS Primario:** `192.168.20.20`
* **Asignación:** Dinámica vía Kea DHCP (Relay en Router Interno).

---

##  Tecnologías Utilizadas

* **OS/Virtualización:** Ubuntu Server 24.04
* **Routing & Switching:** MikroTik RouterOS v7, Cisco IOS
* **Infraestructura Óptica:** Huawei GPON
* **Core Network:** Kea DHCP, BIND9, Chrony
* **Web Stack:** Caddy Server
* **Mail Stack:** Postfix, Dovecot
* **Observabilidad:** Prometheus, Grafana, LibreNMS
* **Traffic Shaping:** LibreQoS

---

##  Estructura del Repositorio

```text
ISP-Project/
├── devices/
│   ├── olt/               # Configuraciones Huawei
│   ├── switch/            # Configuraciones Cisco SG350X
│   └── router/            # Scripts MikroTik (Firewall, NAT, VLANs)
│
├── server/
│   └── vms/
│       ├── dhcp/          # Configuración Kea
│       ├── dns/           # Zonas y conf BIND9
│       ├── ntp/           # Chrony.conf
│       ├── monitoreo/     # Docker-compose para Prometheus/Grafana
│       ├── qos/           # Reglas LibreQoS
│       ├── smtp/          # Configuración Postfix/Dovecot
│       └── web/           # Caddyfiles
│
└── README.md
