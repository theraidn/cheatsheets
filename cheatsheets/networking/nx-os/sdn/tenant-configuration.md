# Cisco ACI Tenant Configuration

## Prerequisites
- APIC GUI/CLI access
- Existing Fabric

## Configuration via APIC GUI
1. **Create Tenant**:
   - Navigation: `Tenant` > `Create Tenant`
   - Name: `my_tenant`
2. **Create Application Profile**:
   - Navigation: `Tenant` > `my_tenant` > `Application Profiles` > `Create Profile`
   - Name: `my_app`
3. **Create EPGs**:
   - Navigation: `Tenant` > `my_tenant` > `my_app` > `Application EPGs` > `Create EPG`
   - Name: `web_epg`
   - Scope: `Application-aware`
4. **Create BDs**:
   - Navigation: `Tenant` > `my_tenant` > `Bridge Domains` > `Create BD`
   - Name: `web_bd`
   - Subnet: `10.10.10.1/24` (Gateway)
5. **Associate EPG with BD**:
   - Navigation: `Tenant` > `my_tenant` > `my_app` > `web_epg` > `BD` > `Add`
   - Select: `web_bd`

## Configuration via Python (ACI Toolkit)
```python
from acia import *

# Connect to APIC
apic = Apic('10.100.1.1', 'admin', 'password')

# Create Tenant
tenant = apic.tenants.create('my_tenant')

# Create Application Profile
app_profile = tenant.application_profiles.create('my_app')

# Create Bridge Domain
bd = tenant.bridge_domains.create('web_bd')
bd.subnets.add('10.10.10.1/24')

# Create EPG
epg = app_profile.epgs.create('web_epg')
epg.bd = bd

# Save Configuration
apic.save()
```
