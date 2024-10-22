#!/usr/bin/bash

echo "Starting audit for open IPv6 ports and firewall rules..."

# Initialize a status flag for the audit
audit_passed=true

# Check for open ports
echo "Checking for open IPv6 ports..."
open_ports=$(ss -6tuln)

# Display the open ports
echo "$open_ports"

# Check if any open ports are listening on non-localhost addresses
if echo "$open_ports" | grep -q 'LISTEN.*:::.*'; then
    echo "Open ports found on non-localhost addresses."
else
    echo "FAIL: No open ports found on non-localhost addresses."
    audit_passed=false
fi

# Check the firewall rules
echo "Checking firewall rules for INPUT chain..."
firewall_rules=$(ip6tables -L INPUT -v -n)

# Display the firewall rules
echo "$firewall_rules"

# Verify that all open ports have corresponding firewall rules
if echo "$firewall_rules" | grep -q 'tcp dpt:22 state NEW'; then
    echo "PASS: Firewall rule for tcp port 22 (NEW connections) is present."
else
    echo "FAIL: Firewall rule for tcp port 22 (NEW connections) is NOT present."
    audit_passed=false
fi

# If any conditions failed, check if IPv6 is disabled
if [ "$audit_passed" = false ]; then
    echo "Checking if IPv6 is disabled on the system..."
    
    output=""
    grubfile="$(find -L /boot -name 'grub.cfg' -type f)"
    
    # Check GRUB configuration for IPv6
    if [ -f "$grubfile" ] && ! grep "^\s*linux" "$grubfile" | grep -vq "ipv6.disable=1"; then
        output="IPv6 is NOT disabled in GRUB config."
    else
        output="IPv6 is disabled in GRUB config."
    fi
    
    # Check sysctl configuration for IPv6
    if grep -Eqs "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" /etc/sysctl.conf \
    /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && \
    grep -Eqs "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b" /etc/sysctl.conf \
    /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
        output="IPv6 is disabled in sysctl config."
    else
        output="IPv6 is NOT disabled in sysctl config."
    fi

    # Check sysctl parameters for IPv6
    if sysctl net.ipv6.conf.all.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" && \
       sysctl net.ipv6.conf.default.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b"; then
        output="IPv6 is disabled in sysctl parameters."
    fi

    # Output the IPv6 status
    if [ -n "$output" ]; then
        echo -e "\n$output"
    else
        echo -e "\n*** IPv6 is enabled on the system ***"
    fi
else
    echo "Audit passed: All necessary conditions for open IPv6 ports and firewall rules are satisfied."
fi

# Final result output
if [ "$audit_passed" = true ]; then
    echo "Audit completed successfully. All checks passed."
else
    echo "Audit failed: One or more checks did not pass."
fi
