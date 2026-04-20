# Cisco NX-OS Routing

## Static Routing
```bash
configure terminal
!
! Default Route
!
ip route 0.0.0.0/0 192.168.1.254
!
! Static Route with Metric
!
ip route 10.0.0.0/8 192.168.1.254 10
!
! Static Route with Tracking
!
ip route 10.0.0.0/8 192.168.1.254 track 1
!
! Verify
!
show ip route
show ip route static
```

## OSPFv2
```bash
configure terminal
!
! Enable OSPF
!
router ospf 100
 router-id 10.10.10.1
 maximum-paths 8
!
! Define Networks
!
address-family ipv4 unicast
  network 10.10.0.0/16 area 0
  network 192.168.1.0/24 area 0
!
! Configure Area Type
!
area 1 stub
area 2 nssa
!
! Redistribute Connected
!
redistribute connected subnets
!
! Verify
!
show ip ospf neighbor
show ip ospf database
```

## OSPFv3 (IPv6)
```bash
configure terminal
!
! Enable OSPFv3
!
ipv6 router ospf 100
 router-id 10.10.10.1
!
! Configure Interfaces
!
interface Ethernet1/1
 ipv6 ospf 100 area 0
!
! Verify
!
show ipv6 ospf neighbor
```

## BGP (AS 65000)
```bash
configure terminal
!
! Configure BGP
!
router bgp 65000
 router-id 10.10.10.1
 bgp log-neighbor-changes
!
! Define Peers
!
neighbor 192.168.1.2 remote-as 65001
 neighbor 192.168.1.2 description PEER-TO-RTR-01
 neighbor 192.168.1.2 send-community both
!
! Address Family
!
address-family ipv4 unicast
  neighbor 192.168.1.2 activate
  network 10.10.0.0/16
!
! Verify
!
show bgp summary
show bgp neighbors
```

## VRF-Lite
```bash
configure terminal
!
! Create VRF
!
vrf context MGMT
 description Management VRF
 rd 65000:1
 address-family ipv4 unicast
  route-target both 65000:1
!
! Assign Interface to VRF
!
interface Ethernet1/1
 no ip address
 vrf MGMT
 ip address 10.200.1.1/24
!
! Configure Routing in VRF
!
router bgp 65000 vrf MGMT
 router-id 10.10.10.1
 address-family ipv4 unicast
  redistribute connected
!
! Verify
!
show vrf
show ip vrf detail
show ip vrf forwarding
```
