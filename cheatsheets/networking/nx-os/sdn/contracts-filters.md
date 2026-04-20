# Cisco ACI Contracts & Filters

## Contracts Overview
- **Contracts**: Define communication between EPGs.
- **Subjects**: Define specific rules within a contract.
- **Filters**: Define the traffic types (protocols/ports) allowed.

## Creating a Contract (APIC GUI)
1. **Create Filter**:
   - Navigation: `Tenant` > `my_tenant` > `Filters` > `Create Filter`
   - Name: `web_filter`
   - Add Rule:
     - Name: `http`
     - Protocol: `TCP`
     - EtherType: `IP`
     - DPort: `80`
2. **Create Subject**:
   - Navigation: `Tenant` > `my_tenant` > `Contracts` > `Create Contract`
   - Name: `web_contract`
   - Add Subject:
     - Name: `web_subject`
     - Add Filter: `web_filter`
3. **Apply Contract**:
   - Navigation: `Tenant` > `my_tenant` > `my_app` > `web_epg` > `Contracts`
   - Add Consumer: `web_contract` (from `web_epg`)
   - Add Provider: `web_contract` (from `db_epg`)

## Verifying Contracts
```bash
!
! Show Contract Details
!
show contract
show contract detail
!
! Show EPG Contracts
!
show epg contract
show epg contract detail
!
! Show Filter Details
!
show filter
show filter detail
```

## APIC GUI Verification

- Navigate: `Tenant` > `my_tenant` > `Application Profiles` > `my_app` > `web_epg` > `Contracts`.
- Verify that the contract appears under **Provided Contracts** on the provider EPG and under **Consumed Contracts** on the consumer EPG.
- Check `Tenant` > `my_tenant` > `Inventory` > `Endpoints` to confirm endpoints are learned in the expected EPGs/VLANs.

## Troubleshooting Checklist (Contracts)

- Confirm the **Filter** contains the correct protocol and destination port (e.g., TCP/80).
- Confirm the **Subject** references the intended filter.
- Confirm the contract is attached to the correct provider and consumer EPGs.
- Confirm the Bridge Domain (BD) and VLAN mapping for each EPG are correct.
- Verify endpoints are learned (`show epg` / `show endpoint`) and that traffic matches the filter criteria.
- If traffic is still blocked, check any service-chaining policies or external L3Out that could affect routing.


## Common Use Cases
- **Web to DB**: Allow TCP 3306 from `web_epg` to `db_epg`.
- **DB to Web**: Allow TCP 3306 from `db_epg` to `web_epg`.
- **External to Web**: Allow TCP 80/443 from `ext_epg` to `web_epg`.
