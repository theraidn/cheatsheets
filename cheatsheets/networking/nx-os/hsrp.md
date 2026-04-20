# Cisco NX-OS HSRP

## Overview
HSRP (Hot Standby Router Protocol) is a Cisco-proprietary first-hop redundancy protocol. NX-OS supports HSRPv2.

> **Note:** NX-OS command syntax and available show-commands may vary by platform and NX-OS version. Verify exact CLI keywords on your device documentation.

## Configuration Example
```bash
configure terminal
!
! Define VLAN Interface
!
interface Vlan10
 description HSRP-GROUP-10
 ip address 192.168.10.1/24
 no shutdown
!
! Configure HSRP
!
interface Vlan10
 standby 10 ip 192.168.10.254
 standby 10 priority 150
 standby 10 preempt delay minimum 60
 standby 10 authentication md5 key-string MySecureKey
 standby 10 track Ethernet1/1 decrement 30
!
! Verify
!
show standby vlan 10
show standby interface Vlan10

! Alternative (varies by NX-OS release):
! Some platforms/versions provide `show hsrp` output; if available, try:
show hsrp
```

## Key Commands
```bash
! Set Priority (Higher wins)
standby <group> priority <1-255>

! Enable Preemption
standby <group> preempt

! Track Interface Down
standby <group> track <interface> decrement <value>

! Authentication (MD5)
standby <group> authentication md5 key-string <string>
```
