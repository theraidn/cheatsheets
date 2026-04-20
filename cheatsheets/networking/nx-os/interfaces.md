# Cisco NX-OS Interface Configuration

## Physical Interface Configuration
```bash
configure terminal
!
! Configure a 10GigE Interface
!
interface Ethernet1/1
 description UPLINK-TO-CORE-01
 no shutdown
 speed 10000
 full-duplex
!
! Configure as Layer 3
!
interface Ethernet1/2
 description SERVER-PORT-1
 no shutdown
 ip address 192.168.1.1/24
 no switchport
!
! Configure as Layer 2 Trunk
!
interface Ethernet1/3
 description TRUNK-TO-SW-02
 no shutdown
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
!
! Port Security
!
interface Ethernet1/4
 description SERVER-PORT-2
 no shutdown
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation shutdown
!
end
copy running-config startup-config
```

## PortChannel (LACP)
```bash
configure terminal
!
! Define the PortChannel
!
interface port-channel10
 description BUNDLE-TO-SERVER
 ip address 192.168.2.1/24
 no switchport
!
! Add Members to the PortChannel
!
interface Ethernet1/5
 no shutdown
 channel-group 10 mode active
!
interface Ethernet1/6
 no shutdown
 channel-group 10 mode active
!
! Verify
!
show port-channel summary
```

## Loopback Interface (for OSPF/BGP ID)
```bash
configure terminal
interface loopback10
 description OSPF-LOOPBACK
 ip address 10.10.10.1/32
 no shutdown
end
```

## VLAN Interface (SVI)
```bash
configure terminal
vlan 100
 name MGMT-POOL
!
interface vlan100
 description MANAGEMENT-VLAN
 ip address 10.10.100.1/24
 no shutdown
end
```
