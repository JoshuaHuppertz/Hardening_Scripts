#!/bin/bash

echo "Starting open ports and firewall rules audit..."

# Define a status flag
audit_passed=true

# Get open TCP and UDP ports
echo "Determining open ports..."
open_ports=$(ss -4tuln | awk '/LISTEN/ {print $5}' | cut -d':' -f2)

# Check if any open ports exist
if [ -z "$open_ports" ]; then
    echo "No open ports found."
    exit 0
fi

echo "Open ports found: $open_ports"

# Get iptables rules
echo "Retrieving firewall rules..."
firewall_rules=$(iptables -L INPUT -v -n)

# Check for firewall rules corresponding to each open port
for port in $open_ports; do
    # Check for firewall rule for this port
    if echo "$firewall_rules" | grep -qE "tcp .* dpt:$port"; then
        echo "PASS: Firewall rule for TCP port $port exists."
    else
        echo "FAIL: No firewall rule for TCP port $port."
        audit_passed=false
    fi
done

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All open ports have corresponding firewall rules."
else
    echo "Audit failed: One or more open ports do not have corresponding firewall rules."
fi
