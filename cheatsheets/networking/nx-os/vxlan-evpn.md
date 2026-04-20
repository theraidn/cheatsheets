# Cisco NX-OS VXLAN & EVPN

## Prerequisites
- Nexus 9000 Series
- NX-OS 7.0(3)I2(1) or later
- Data Center Best Practice (DCB) features enabled

> **Quick NX-OS checks:**
- Ensure required features are enabled:
```bash
show feature | include vxlan
show feature | include evpn
```

If a feature is not enabled, enable it with `feature vxlan` or `feature evpn` and verify again.

> **Note:** VXLAN/EVPN CLI and feature names can differ between NX-OS releases; confirm exact syntax on your platform.

## VXLAN EVPN Configuration

### 1. Enable VXLAN
```bash
configure terminal
!
! Enable VXLAN Feature
!
feature vxlan
!
! Configure L2 VPN (VXLAN)
!
l2vpn vxlan
  vtep source loopback1
  multicast source loopback1
  no shutdown
!
! Verify
!
show vxlan vtep
```

### 2. Configure VTEP (VXLAN Tunnel End Point)
```bash
configure terminal
!
! Loopback for VTEP ID
!
interface loopback1
 description VTEP-LOOPBACK
 ip address 10.100.10.1/32
!
! VTEP Configuration
!
interface loopback1
 vrf default
!
! VXLAN Tunnel Source
!
vtep source loopback1
!
! Verify
!
show vtep
```

### 3. Configure EVPN (Layer 2 EVPN)
```bash
configure terminal
!
! Enable EVPN
!
feature evpn
!
! Configure EVPN VRF
!
vrf context L2VPN
  rd 10.100.10.1:1
  address-family ipv4 unicast
   route-target both 100:1
   redistribute evpn
!
! Configure EVPN Address Family
!
router bgp 65000
  router-id 10.100.10.1
  address-family evpn
   redistribute connected
!
! Verify
!
show evpn summary
show bgp evpn route
```

### 4. Configure VXLAN VNI
```bash
configure terminal
!
! Define VNI
!
vlan 100
  name USERS
!
! Map VLAN to VNI
!
vlan 100
  member vni 100100
  no shutdown
!
! Verify
!
show vxlan vlan
```

### 5. Verify VXLAN EVPN
```bash
show vxlan vlan
show vxlan vtep
show evpn summary
show bgp evpn route
```
