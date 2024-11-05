#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.1.11"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Arrays für die Speicherung der Ergebnisse
a_file=()  # Welt-writable Dateien
a_dir=()   # Welt-writable Verzeichnisse ohne Sticky Bit

# Ausschlussmuster für Pfade definieren
a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path \
"*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path \
"*/kubelet/plugins/*" -a ! -path "/sys/*" -a ! -path "/snap/*")

# Durchsuche die gemounteten Dateisysteme
while IFS= read -r l_mount; do
    # Suche nach welt-writable Dateien und Verzeichnissen
    while IFS= read -r -d $'\0' l_file; do
        if [ -e "$l_file" ]; then
            [ -f "$l_file" ] && a_file+=("$l_file")  # Füge welt-writable Dateien hinzu
            if [ -d "$l_file" ]; then  # Füge Verzeichnisse ohne Sticky Bit hinzu
                l_mode="$(stat -Lc '%#a' "$l_file")"
                if [ ! $(( l_mode & 01000 )) -gt 0 ]; then  # Prüfe, ob Sticky Bit gesetzt ist
                    a_dir+=("$l_file")
                fi
            fi
        fi
    done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2> /dev/null)
done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^(\/run\/user\/|\/tmp|\/var\/tmp)/){print $2}')

# Überprüfe, ob welt-writable Dateien existieren
if [ ${#a_file[@]} -eq 0 ]; then
    l_output+="\n - Keine welt-writable Dateien auf dem lokalen Dateisystem."
else
    l_output2+="\n - Es gibt \"${#a_file[@]}\" welt-writable Dateien auf dem System.\n - Folgende Dateien sind welt-writable:\n$(printf '%s\n' "${a_file[@]}")\n - Ende der Liste\n"
fi

# Überprüfe, ob welt-writable Verzeichnisse ohne Sticky Bit existieren
if [ ${#a_dir[@]} -eq 0 ]; then
    l_output+="\n - Der Sticky Bit ist auf allen welt-writable Verzeichnissen auf dem lokalen Dateisystem gesetzt."
else
    l_output2+="\n - Es gibt \"${#a_dir[@]}\" welt-writable Verzeichnisse ohne Sticky Bit auf dem System.\n - Folgende Verzeichnisse sind welt-writable ohne Sticky Bit:\n$(printf '%s\n' "${a_dir[@]}")\n - Ende der Liste\n"
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
