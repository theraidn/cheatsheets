# Cisco ACI Troubleshooting

## Common Issues & Solutions

### 1. Fabric Not Ready
- **Symptom**: APIC reports `Fabric not ready`.
- **Solution**:
  - Check `show fabric status` on all nodes.
  - Ensure all Spine/Leaf nodes are powered on and connected.
  - Verify fabric IP pool is not exhausted.

### 2. Endpoint Not Learning
- **Symptom**: No endpoints appear in `show vxlan endpoint`.
- **Solution**:
  - Check `show vxlan vni` on all Leafs.
  - Verify EPG membership (VLAN/Port binding).
  - Ensure MAC address limit is not reached.
  - Check for STP issues (should be disabled in ACI).

### 3. Connectivity Issues
- **Symptom**: Ping/Traceroute fails between EPGs.
- **Solution**:
  - Verify Contracts are applied correctly.
  - Check Filter rules (Protocol/Port).
  - Verify BD Subnet configuration.
  - Check `show contract` and `show epg contract`.

### 4. VTEP Not Up
- **Symptom**: VTEP state is `down`.
- **Solution**:
  - Check `show vxlan vtep` on all Leafs.
  - Verify Loopback interface is up.
  - Check OSPF/BGP peering between Spines and Leafs.

## Useful Commands
```bash
!
! VXLAN
!
show vxlan endpoint
show vxlan vni
show vxlan vtep
! Ensure features are enabled
show feature | include vxlan
show feature | include evpn
!
! EVPN
!
show evpn route
show evpn summary
!
! Contracts
!
show contract
show epg contract
show filter
!
! EPG
!
show epg
show epg detail
!
! BD
!
show bd
show bd detail
!
! Fabric
!
show fabric
show fabric node
show fabric summary
```
