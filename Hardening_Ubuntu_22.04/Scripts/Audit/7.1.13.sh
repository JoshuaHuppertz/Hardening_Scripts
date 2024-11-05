#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.1.13"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""
a_suid=(); a_sgid=()  # Arrays für SUID und SGID Dateien

# Durchsuche die gemounteten Dateisysteme
while IFS= read -r l_mount_point; do
    # Überprüfen, ob der Mount-Punkt nicht /run/usr ist und kein noexec-Flag hat
    if ! grep -Pqs '^\h*\/run\/usr\b' <<< "$l_mount_point" && ! grep -Pqs -- '\bnoexec\b' <<< "$(findmnt -krn "$l_mount_point")"; then
        # Suche nach SUID und SGID Dateien
        while IFS= read -r -d $'\0' l_file; do
            if [ -e "$l_file" ]; then
                l_mode="$(stat -Lc '%#a' "$l_file")"
                [ $(( $l_mode & 04000 )) -gt 0 ] && a_suid+=("$l_file")  # Füge SUID-Dateien hinzu
                [ $(( $l_mode & 02000 )) -gt 0 ] && a_sgid+=("$l_file")  # Füge SGID-Dateien hinzu
            fi
        done < <(find "$l_mount_point" -xdev -type f \( -perm -2000 -o -perm -4000 \) -print0 2>/dev/null)
    fi
done <<< "$(findmnt -Derno target)"

# Überprüfen, ob SUID-Dateien existieren
if [ ${#a_suid[@]} -eq 0 ]; then
    l_output+="\n - Es existieren keine ausführbaren SUID-Dateien auf dem System."
else
    l_output2+="\n - Liste der \"$(printf '%s' "${#a_suid[@]}")\" SUID ausführbaren Dateien:\n$(printf '%s\n' "${a_suid[@]}")\n - Ende der Liste -\n"
fi

# Überprüfen, ob SGID-Dateien existieren
if [ ${#a_sgid[@]} -eq 0 ]; then
    l_output+="\n - Es existieren keine SGID-Dateien auf dem System."
else
    l_output2+="\n - Liste der \"$(printf '%s' "${#a_sgid[@]}")\" SGID ausführbaren Dateien:\n$(printf '%s\n' "${a_sgid[@]}")\n - Ende der Liste -\n"
fi

# Erinnerung zur Überprüfung der Listen
[ -n "$l_output2" ] && l_output2+="\n- Überprüfen Sie die vorhergehenden Listen der SUID- und/oder SGID-Dateien, um\n- sicherzustellen, dass keine unerwünschten Programme auf das System eingeführt wurden.\n"

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
