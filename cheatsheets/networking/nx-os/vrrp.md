# Cisco NX-OS VRRP

## Overview
VRRP (Virtual Router Redundancy Protocol) is an open standard (RFC 5798) for first-hop redundancy. NX-OS supports VRRPv3.

## Configuration Example
```bash
configure terminal
!
! Define VLAN Interface
!
interface Vlan10
 description VRRP-GROUP-10
 ip address 192.168.10.1/24
 no shutdown
!
! Configure VRRP
!
interface Vlan10
 vrrp 10 ip 192.168.10.254
 vrrp 10 priority 150
 vrrp 10 preempt delay minimum 60
 vrrp 10 authentication type md5 key-string MySecureKey
 vrrp 10 track Ethernet1/1 decrement 30
!
! Verify
!
show vrrp vlan 10
show vrrp interface Vlan10
```

## Key Commands
```bash
! Set Priority (Higher wins)
vrrp <group> priority <1-255>

! Enable Preemption
vrrp <group> preempt

! Track Interface Down
vrrp <group> track <interface> decrement <value>

! Authentication (MD5)
vrrp <group> authentication type md5 key-string <string>
```
