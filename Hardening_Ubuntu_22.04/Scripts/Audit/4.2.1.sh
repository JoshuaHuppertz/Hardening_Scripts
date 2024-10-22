#!/usr/bin/env bash
{
    # Überprüfen, ob nftables installiert ist
    if dpkg-query -s nftables &>/dev/null; then
        echo -e "\n- Audit Result:\n ** PASS **\n- nftables is installed\n"
    else
        echo -e "\n- Audit Result:\n ** FAIL **\n- nftables is not installed\n"
    fi
}
