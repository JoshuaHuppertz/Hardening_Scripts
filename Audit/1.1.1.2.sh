#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.1.2"

{
    l_output=""  l_output2=""  l_output3=""  l_dl=""
    l_mname="freevxfs"  # Setze den Modulnamen
    l_mtype="fs"        # Setze den Modultyp
    l_searchloc="/lib/modprobe.d/*.conf /usr/local/lib/modprobe.d/*.conf /run/modprobe.d/*.conf /etc/modprobe.d/*.conf"
    l_mpath="/lib/modules/**/kernel/$l_mtype"
    l_mpname="$(tr '-' '_' <<< "$l_mname")"
    l_mndir="$(tr '-' '/' <<< "$l_mname")"

    # Ergebnisverzeichnis
    RESULT_DIR="$(dirname "$0")/../Results"
    mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

    module_loadable_chk() {
        # Überprüfung, ob das Modul ladbar ist
        l_loadable="$(modprobe -n -v "$l_mname")"
        [ "$(wc -l <<< "$l_loadable")" -gt "1" ] && \
        l_loadable="$(grep -P -- "(^\h*install|\b$l_mname)\b" <<< "$l_loadable")"
        
        if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
            l_output="$l_output\n - module: \"$l_mname\" is not loadable: \"$l_loadable\""
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loadable: \"$l_loadable\""
        fi
    }

    module_loaded_chk() {
        # Überprüfung, ob das Modul geladen ist
        if ! lsmod | grep "$l_mname" > /dev/null 2>&1; then
            l_output="$l_output\n - module: \"$l_mname\" is not loaded"
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loaded"
        fi
    }

    module_deny_chk() {
        # Überprüfung, ob das Modul auf der Deny-Liste steht
        l_dl="y"
        if modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
            l_output="$l_output\n - module: \"$l_mname\" is deny listed in: \"$(grep -Pls -- "^\h*blacklist\h+$l_mname\b" $l_searchloc)\""
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is not deny listed"
        fi
    }

    # Überprüfung, ob das Modul auf dem System existiert
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir")" ]; then
            l_output3="$l_output3\n - \"$l_mdir\""
            [ "$l_dl" != "y" ] && module_deny_chk
            
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                module_loadable_chk
                module_loaded_chk
            fi
        else
            l_output="$l_output\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\""
        fi
    done

    # Prüfungsergebnisse speichern und Trennlinie hinzufügen
    SEPARATOR="-------------------------------------------------"

    # Ergebnisse ausgeben
    if [ -n "$l_output3" ]; then
        echo -e "\n\n -- INFO --\n - module: \"$l_mname\" exists in:$l_output3"
    fi
    
    if [ -z "$l_output2" ]; then
        touch "$RESULT_DIR/pass.txt"
        echo -e "$SEPARATOR\nAudit: $AUDIT_NAME\n$l_mname: PASS\n$l_output\n" >> "$RESULT_DIR/pass.txt"
    else
        touch "$RESULT_DIR/fail.txt"
        echo -e "$SEPARATOR\nAudit: $AUDIT_NAME\n$l_mname: FAIL\n$l_output2\n" >> "$RESULT_DIR/fail.txt"
        echo -e "\n- Correctly set:\n$l_output\n" >> "$RESULT_DIR/fail.txt"
    fi
}
