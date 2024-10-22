#!/bin/bash

echo "Starting incoming and outgoing connection rules audit..."

# Define a status flag
audit_passed=true

# Expected incoming connection rules (site policy)
expected_incoming=(
  "ip protocol tcp ct state established accept"
  "ip protocol udp ct state established accept"
  "ip protocol icmp ct state established accept"
)

# Expected outgoing connection rules (site policy)
expected_outgoing=(
  "ip protocol tcp ct state established,related,new accept"
  "ip protocol udp ct state established,related,new accept"
  "ip protocol icmp ct state established,related,new accept"
)

# Check established incoming connections
echo "Verifying incoming connection rules match site policy..."
incoming_rules=$(nft list ruleset | awk '/hook input/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state')

# Check if all expected incoming rules are present
for rule in "${expected_incoming[@]}"; do
  if echo "$incoming_rules" | grep -q "$rule"; then
    echo "PASS: Found incoming rule: $rule"
  else
    echo "FAIL: Missing incoming rule: $rule"
    audit_passed=false
  fi
done

# Check new and established outbound connections
echo "Verifying outbound connection rules match site policy..."
outgoing_rules=$(nft list ruleset | awk '/hook output/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state')

# Check if all expected outgoing rules are present
for rule in "${expected_outgoing[@]}"; do
  if echo "$outgoing_rules" | grep -q "$rule"; then
    echo "PASS: Found outgoing rule: $rule"
  else
    echo "FAIL: Missing outgoing rule: $rule"
    audit_passed=false
  fi
done

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All incoming and outgoing rules match the site policy."
else
    echo "Audit failed: One or more incoming or outgoing rules do not match the site policy."
fi
