#!/usr/bin/env bash
{
    # Überprüfen, ob eine nftables-Tabelle existiert
    nft_tables=$(nft list tables)

    # Pass/Fail-Kriterium: Überprüfen, ob die Ausgabe "table" enthält
    if [[ "$nft_tables" == *"table"* ]]; then
        echo -e "\n- Audit Result:\n ** PASS **\n- Existing nftables tables found:\n$nft_tables\n"
    else
        echo -e "\n- Audit Result:\n ** FAIL **\n- No nftables tables found. The output was:\n$nft_tables\n"
    fi
}
