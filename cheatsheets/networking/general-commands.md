# Networking — Common Commands

- Show addresses and interfaces:
```bash
ip addr
```

- Show routing table:
```bash
ip route
```

- Traceroute / path troubleshooting:
```bash
traceroute 8.8.8.8
mtr -r -c 100 example.com
```

- Quick packet capture (use with care):
```bash
sudo tcpdump -n -i <iface> port 80
```
