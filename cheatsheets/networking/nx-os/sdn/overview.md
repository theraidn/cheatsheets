# Cisco ACI Overview

## Architecture Components
- **APIC** (Application Policy Infrastructure Controller): Management plane.
- **Spine Switches**: Core of the fabric.
- **Leaf Switches**: Access layer (servers, routers, etc.).
- **BD** (Bridge Domain): Layer 2 broadcast domain.
- **EPG** (Endpoint Group): Logical grouping of endpoints.
- **AP** (Application Profile): Container for EPGs.
- **Tenant**: Administrative boundary.

## Key Concepts
- **Underlay**: Physical network infrastructure (Spine/Leaf).
- **Overlay**: VXLAN-based logical network.
- **Contract**: Policy between EPGs.
- **Subject**: Filters in a contract.
- **Filter**: List of actions (permit/deny).
