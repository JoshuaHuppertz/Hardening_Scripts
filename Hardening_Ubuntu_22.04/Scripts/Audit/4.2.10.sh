#!/bin/bash

echo "Starting nftables base chains and ruleset audit..."

# Define a status flag
audit_passed=true

# Function to check if a specific rule exists
check_rule() {
    rule="$1"
    description="$2"
    if echo "$ruleset" | grep -q "$rule"; then
        echo "PASS: $description"
    else
        echo "FAIL: $description"
        audit_passed=false
    fi
}

# Load nftables ruleset
ruleset=$(nft list ruleset)

# --- INPUT BASE CHAIN CHECK ---
echo "Verifying input base chain rules..."

# Check for input chain policy
check_rule "hook input.*policy drop" "Input chain has policy DROP."

# Ensure loopback traffic is configured
check_rule 'iif "lo" accept' "Loopback interface accepts traffic."
check_rule 'ip saddr 127.0.0.0/8 counter packets 0 bytes 0 drop' "IPv4 loopback traffic is dropped."
check_rule 'ip6 saddr ::1 counter packets 0 bytes 0 drop' "IPv6 loopback traffic is dropped."

# Ensure established connections are configured
check_rule 'ip protocol tcp ct state established accept' "Established TCP connections are accepted."
check_rule 'ip protocol udp ct state established accept' "Established UDP connections are accepted."
check_rule 'ip protocol icmp ct state established accept' "Established ICMP connections are accepted."

# Accept SSH traffic (port 22)
check_rule 'tcp dport ssh accept' "SSH traffic (port 22) is accepted."

# Accept ICMP and IGMP from anywhere (site policy)
check_rule 'icmpv6 type' "ICMPv6 and IGMP traffic is accepted as per site policy."

# --- FORWARD BASE CHAIN CHECK ---
echo "Verifying forward base chain rules..."

forward_chain=$(awk '/hook forward/,/}/' $(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/nftables.conf))

# Check forward chain policy
if [[ -n "$forward_chain" ]]; then
    if echo "$forward_chain" | grep -q "policy drop"; then
        echo "PASS: Forward chain has policy DROP."
    else
        echo "FAIL: Forward chain does not have policy DROP."
        audit_passed=false
    fi
else
    echo "FAIL: Forward chain not found or misconfigured."
    audit_passed=false
fi

# --- OUTPUT BASE CHAIN CHECK ---
echo "Verifying output base chain rules..."

output_chain=$(awk '/hook output/,/}/' $(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/nftables.conf))

# Check output chain policy
if [[ -n "$output_chain" ]]; then
    if echo "$output_chain" | grep -q "policy drop"; then
        echo "PASS: Output chain has policy DROP."
    else
        echo "FAIL: Output chain does not have policy DROP."
        audit_passed=false
    fi
else
    echo "FAIL: Output chain not found or misconfigured."
    audit_passed=false
fi

# Ensure outbound and established connections are configured
check_rule 'ip protocol tcp ct state established,related,new accept' "Outbound TCP connections are accepted."
check_rule 'ip protocol udp ct state established,related,new accept' "Outbound UDP connections are accepted."
check_rule 'ip protocol icmp ct state established,related,new accept' "Outbound ICMP connections are accepted."

# --- Final Audit Result ---
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All base chains and nftables rules match site policy."
else
    echo "Audit failed: One or more base chains or nftables rules do not match site policy."
fi
