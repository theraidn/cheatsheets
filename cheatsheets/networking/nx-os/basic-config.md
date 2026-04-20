# Cisco NX-OS Basic Configuration

## Initial Setup
```bash
configure terminal
hostname dc-core-01
ip domain-name example.com
aaa new-model
aaa authorization exec default local
!
! Configure Management Interface (MGMT0)
!
interface mgmt0
 ip address 10.0.0.10/24
!
! Note: set the management default gateway as a global route
ip route 0.0.0.0/0 10.0.0.1
!
! Configure SSH Access
!
ip ssh version 2
ip domain-name example.com
crypto key generate rsa modulus 2048
username admin password YourStrongPassword role network-admin
!
! Configure VTY Lines
!
line vty
 login local
 transport input ssh
!
! Save Configuration
!
copy running-config startup-config
```

## System Settings
```bash
! Set Timezone
clock timezone EST -5 0
clock summer-time EDT recurring

! Set NTP
ntp server 10.0.0.2 iburst prefer

! Configure Logging
logging host 10.0.0.3 facility local7
logging monitor informational
logging trap informational
```

## Boot Configuration
```bash
! Set Boot Flash
boot system bootflash:nxos.9.3.6.bin
reload
```
