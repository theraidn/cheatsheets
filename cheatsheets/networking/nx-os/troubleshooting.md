# Cisco NX-OS Troubleshooting

## Show Commands

### 1. Interface Status
```bash
show interface status
show interface Ethernet1/1
show interface counters
```

### 2. VLAN & Switchport
```bash
show vlan brief
show vlan id 10
show interface Ethernet1/1 switchport
show spanning-tree vlan 10
```

### 3. Routing
```bash
show ip route
show ip route static
show ip route bgp
show ip ospf neighbor
show bgp summary
show bgp neighbors
```

### 4. VXLAN & EVPN
```bash
show vxlan vtep
show vxlan vlan
show evpn summary
show bgp evpn route
show vtep
```

### 5. VRF
```bash
show vrf
show vrf detail
show ip vrf forwarding
```

## Debug Commands (Use with Caution)
```bash
debug ip ospf adjacency
debug ip bgp updates
debug evpn route
```

## Clear Commands
```bash
clear ip route *
clear bgp neighbor *
clear evpn route
```

## Logging
```bash
show logging
show logging | include ERR
show logging | include %
```
