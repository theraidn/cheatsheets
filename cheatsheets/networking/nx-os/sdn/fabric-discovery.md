# Cisco ACI Fabric Discovery

## Fabric Discovery Commands (on Spine/Leaf)
```bash
!
! Check Fabric Status
!
show fabric
show fabric node
show fabric summary
!
! Check Spine/Leaf Connectivity
!
show fabric spine
show fabric leaf
!
! Check Interfaces
!
show interface brief
show interface description
!
! Check VXLAN Endpoints
!
show vxlan endpoint
show vxlan vni
!
! Check EVPN Routes
!
show evpn route
show evpn summary
```

## Common Troubleshooting Steps
1. **Check Fabric Status**: Ensure all nodes are in `active` state.
2. **Check Interfaces**: Verify uplinks are `up/up`.
3. **Check VXLAN**: Ensure VTEPs are learning endpoints.
	- Verify NX-OS VXLAN/EVPN features are enabled on Leafs/Spines:
```bash
show feature | include vxlan
show feature | include evpn
```
4. **Check EVPN**: Ensure EVPN routes are present.
5. **Check Contracts**: Ensure contracts are applied correctly.
