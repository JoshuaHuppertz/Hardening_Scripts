#!/usr/bin/env bash
{
    # Überprüfen, ob die Chains für INPUT, FORWARD und OUTPUT existieren
    input_chain=$(nft list ruleset | grep 'hook input')
    forward_chain=$(nft list ruleset | grep 'hook forward')
    output_chain=$(nft list ruleset | grep 'hook output')

    # Pass/Fail-Kriterium für INPUT
    if [[ -n "$input_chain" ]]; then
        input_result="** PASS **: Base chain for INPUT exists.\nDetails: $input_chain\n"
    else
        input_result="** FAIL **: No base chain for INPUT found.\n"
    fi

    # Pass/Fail-Kriterium für FORWARD
    if [[ -n "$forward_chain" ]]; then
        forward_result="** PASS **: Base chain for FORWARD exists.\nDetails: $forward_chain\n"
    else
        forward_result="** FAIL **: No base chain for FORWARD found.\n"
    fi

    # Pass/Fail-Kriterium für OUTPUT
    if [[ -n "$output_chain" ]]; then
        output_result="** PASS **: Base chain for OUTPUT exists.\nDetails: $output_chain\n"
    else
        output_result="** FAIL **: No base chain for OUTPUT found.\n"
    fi

    # Gesamte Ausgabe
    echo -e "\n- Audit Result for nftables Chains -\n"
    echo -e "$input_result"
    echo -e "$forward_result"
    echo -e "$output_result"
}
