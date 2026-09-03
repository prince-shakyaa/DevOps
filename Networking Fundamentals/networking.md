# Network Diagnostics

A practical guide to troubleshooting and exploring network configurations.

## Essential Tools
- **ping**: Tests reachability of a host using ICMP echo requests.
- **ip**: The modern replacement for `ifconfig`. Use `ip a` for addresses and `ip route` for routing tables.
- **ss**: Shows socket statistics. Use `ss -tulpn` to see listening ports and associated processes.
- **curl / wget**: Tools for transferring data from or to a server. `curl -I` is great for checking HTTP headers.
- **nslookup**: Queries DNS to resolve domain names to IP addresses.
- **traceroute**: Maps the path packets take to reach a destination.
- **hostname**: Displays the system's network name.
