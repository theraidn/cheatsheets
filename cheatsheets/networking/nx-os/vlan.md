# Cisco NX-OS VLAN & Switchport

## VLAN Creation & Management
```bash
configure terminal
!
! Create VLANs
!
vlan 10
 name USERS
vlan 20
 name SERVERS
vlan 30
 name VOICE
!
! Set VLAN Name (Optional)
!
vlan 10
 name USERS
!
! Assign Interface to VLAN
!
interface Ethernet1/1
 switchport mode access
 switchport access vlan 10
!
! Verify
!
show vlan brief
show vlan id 10

> **Note:** Some spanning-tree and VLAN command syntax varies between IOS and NX-OS; verify on your target NX-OS version.
```

## Trunk Configuration
```bash
configure terminal
!
! Configure Trunk
!
interface Ethernet1/10
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,999
!
! Verify
!
show interfaces trunk
```

## Voice VLAN
```bash
configure terminal
!
! Configure Voice VLAN
!
interface Ethernet1/11
 switchport mode access
 switchport access vlan 10
 switchport voice vlan 30
 spanning-tree portfast
 spanning-tree bpduguard enable
!
! Verify
!
show interfaces status
```

## Spanning Tree (Rapid-PVST+ or MST)
```bash
configure terminal
!
! Enable Rapid-PVST+
!
spanning-tree mode rapid-pvst
!
! Configure Root Primary/Secondary
!
spanning-tree vlan 10 root primary
spanning-tree vlan 20 root secondary
!
! Configure PortFast for Access Ports
!
interface range Ethernet1/1 - Ethernet1/24
 spanning-tree portfast
 spanning-tree bpduguard enable
!
! Verify
!
show spanning-tree vlan 10
```
