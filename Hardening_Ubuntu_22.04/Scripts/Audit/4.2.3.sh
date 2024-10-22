#!/usr/bin/env bash
{
    # Überprüfen von iptables
    iptables_rules=$(iptables -L)
    ip6tables_rules=$(ip6tables -L)

    # Überprüfen, ob iptables keine Regeln hat
    if [[ "$iptables_rules" == *"Chain"* ]]; then
        echo -e "\n- Audit Result for iptables:\n ** FAIL **\n- Existing rules found in iptables:\n$iptables_rules\n"
    else
        echo -e "\n- Audit Result for iptables:\n ** PASS **\n- No rules found in iptables\n"
    fi

    # Überprüfen, ob ip6tables keine Regeln hat
    if [[ "$ip6tables_rules" == *"Chain"* ]]; then
        echo -e "\n- Audit Result for ip6tables:\n ** FAIL **\n- Existing rules found in ip6tables:\n$ip6tables_rules\n"
    else
        echo -e "\n- Audit Result for ip6tables:\n ** PASS **\n- No rules found in ip6tables\n"
    fi
}
