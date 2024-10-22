#!/usr/bin/env bash
{
    # Überprüfen, ob ufw nicht installiert ist
    if ! dpkg-query -s ufw &>/dev/null; then
        echo -e "\n- Audit Result:\n ** PASS **\n- ufw is not installed\n"
        exit 0
    fi

    # Überprüfen, ob ufw inaktiv ist
    ufw_status=$(ufw status | grep 'Status:')
    systemctl_status=$(systemctl is-enabled ufw.service)

    if [[ "$ufw_status" == *"inactive"* && "$systemctl_status" == *"masked"* ]]; then
        echo -e "\n- Audit Result:\n ** PASS **\n- ufw is inactive and service is masked\n"
    else
        echo -e "\n- Audit Result:\n ** FAIL **\n- ufw is installed or active\n"
        echo -e "- Current ufw status: $ufw_status"
        echo -e "- Current systemd service status: $systemctl_status\n"
    fi
}
