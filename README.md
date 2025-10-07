# Proyecto ISP - Infraestructura II

## Descripción General
Implementación de una red GPON (Gigabit Passive Optical Network) para entorno académico, integrando dispositivos físicos y servicios virtualizados sobre OpenStack. El proyecto incluye segmentación de red mediante VLANs, servicios core de red, monitoreo, y provisión de servicios a clientes finales.

## Topología de Red

### Dispositivos Físicos

1. **ONTs** - Optical Network Terminals (clientes finales)
2. **OLT** - Optical Line Terminal (cabecera GPON)
3. **Switch** - Switch gestionable con soporte VLAN y trunk
4. **Router interno** - Router del proyecto con interfaces VLAN
5. **Router universidad** - Conexión a Internet (Red Universitaria)
6. **Servidor físico** - Ubuntu con OpenStack para VMs

7. ### Conexiones Físicas

- **ONT ↔ OLT**: Fibra óptica
- **OLT ↔ Switch**: Ethernet (puerto Gi1/0/1)
- **Switch ↔ Router interno**: Trunk (puerto Gi1/0/2)
- **Switch ↔ Servidor**: Trunk (puerto Gi1/0/10)
- **Router interno ↔ Router universidad**: Ethernet (Gi0/0/0)

## Segmentación de Red - VLANs

| VLAN | Nombre            | Subred              | Gateway         | Propósito                                    |
|------|-------------------|---------------------|-----------------|----------------------------------------------|
| 10   | Gestion           | 192.168.10.0/24     | 192.168.10.1    | Administración de dispositivos de red        |
| 20   | Servicios_Core    | 192.168.20.0/24     | 192.168.20.1    | Servicios críticos (DHCP, RADIUS, QoS)       |
| 30   | Monitoreo         | 192.168.30.0/24     | 192.168.30.1    | Sistemas de monitoreo y métricas             |
| 40   | Servicios_Red     | 192.168.40.0/24     | 192.168.40.1    | Servicios de infraestructura (DNS, NTP, NAT) |
| 50   | Web               | 192.168.50.0/24     | 192.168.50.1    | Servidores web y balanceadores               |
| 100  | Clientes_GPON     | 192.168.100.0/24    | 192.168.100.1   | Clientes finales conectados via GPON         |


## Direccionamiento IP

### Dispositivos Físicos
| Dispositivo          | Interface/VLAN      | Dirección IP       | Máscara         | Descripción              |
|----------------------|---------------------|--------------------|-----------------|--------------------------|
| Switch               | VLAN 10             | 192.168.10.254     | 255.255.255.0   | Gestión del switch       |
| Router interno       | Gi0/0/1.10          | 192.168.10.1       | 255.255.255.0   | Gateway VLAN Gestión     |
| Router interno       | Gi0/0/1.20          | 192.168.20.1       | 255.255.255.0   | Gateway VLAN Servicios Core |
| Router interno       | Gi0/0/1.30          | 192.168.30.1       | 255.255.255.0   | Gateway VLAN Monitoreo   |
| Router interno       | Gi0/0/1.40          | 192.168.40.1       | 255.255.255.0   | Gateway VLAN Servicios Red |
| Router interno       | Gi0/0/1.50          | 192.168.50.1       | 255.255.255.0   | Gateway VLAN Web         |
| Router interno       | Gi0/0/1.100         | 192.168.100.1      | 255.255.255.0   | Gateway VLAN Clientes    |
| Router interno       | Gi0/0/0             | DHCP               | -               | Salida a Internet        |

### Máquinas Virtuales (OpenStack)
| Servicio              | Hostname       | VLAN | Dirección IP      | Descripción                          |
|-----------------------|----------------|------|-------------------|--------------------------------------|
| DHCP (KEA)            | vm-dhcp        | 20   | 192.168.20.10     | Servidor DHCP para clientes          |
| LibreQoS              | vm-qos         | 20   | 192.168.20.20     | Gestión de calidad de servicio       |
| FreeRADIUS            | vm-radius      | 20   | 192.168.20.30     | Autenticación AAA                    |
| NAT                   | vm-nat         | 40   | 192.168.40.10     | Network Address Translation          |
| BIND9 (DNS)           | vm-dns         | 40   | 192.168.40.20     | Servidor DNS                         |
| Chrony (NTP)          | vm-ntp         | 40   | 192.168.40.30     | Sincronización de tiempo             |
| LibreNMS              | vm-nms         | 30   | 192.168.30.10     | Monitoreo de red                     |
| Grafana/Prometheus    | vm-metrics     | 30   | 192.168.30.20     | Visualización de métricas            |
| Balanceador de Carga  | vm-lb          | 50   | 192.168.50.10     | HAProxy/NGINX balanceador            |
| Servidor Web          | vm-web         | 50   | 192.168.50.20     | Apache/NGINX servidor web            |

### Servicios Core (VLAN 20)
- **DHCP (KEA)**: Asignación dinámica de IPs a clientes
- **LibreQoS**: Control de ancho de banda y QoS
- **FreeRADIUS**: Autenticación, autorización y accounting

### Servicios de Red (VLAN 40)
- **BIND9**: Resolución de nombres de dominio
- **Chrony**: Sincronización de tiempo NTP
- **NAT**: Traducción de direcciones para acceso a Internet

### Monitoreo (VLAN 30)
- **LibreNMS**: Monitoreo SNMP de dispositivos de red
- **Grafana/Prometheus**: Recolección y visualización de métricas

### Servicios Web (VLAN 50)
- **Balanceador de carga**: Distribución de tráfico entre servidores
- **Servidor Web**: Hosting de aplicaciones y contenido

## Estructura del Repositorio

```proyecto-gpon-infra2/
├── dispositivos/                    
│   ├── olt/                          
│   │   └── configs/                              
│   │
│   ├── switch/                       
│   │   └── configs/
│   │
│   └── router/                       
│       └── configs/
│
├── servidor/                        
│   ├── openstack-config/            
│   └── vms/                         
│       ├── dhcp/                 
│       │   └── config/
│       │
│       ├── radius/                 
│       │   └── config/
│       │
│       ├── qos/                     
│       │   └── config/
│       │
│       ├── dns/                    
│       │   └── config/
│       │
│       ├── ntp/                    
│       │   └── config/
│       │
│       ├── monitoreo/              
│       │   ├── librenms/
│       │   └── grafana-prometheus/
│       │
│       └── web/                      
│           ├── balanceador/          
│           └── servidor-web/         
│
├── direccionamiento/                 
│   ├── tabla_ips.md
│   └── plan_subnetting.md
│
├── vlans/                           
│   └── tabla_vlans.md
│
└──  topologia/                        
    ├── diagrama.png
    └── descripcion.md

