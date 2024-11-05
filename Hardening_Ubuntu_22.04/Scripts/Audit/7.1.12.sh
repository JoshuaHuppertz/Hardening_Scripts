#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.1.12"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""
a_nouser=()  # Array für unbesessene Dateien
a_nogroup=() # Array für ungruppierte Dateien

# Ausschlussmuster für Pfade definieren
a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path \
"*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path \
"*/kubelet/plugins/*" -a ! -path "/sys/fs/cgroup/memory/*" -a ! -path \
"/var/*/private/*")

# Durchsuche die gemounteten Dateisysteme
while IFS= read -r l_mount; do
    # Suche nach Dateien oder Verzeichnissen ohne Eigentümer oder Gruppe
    while IFS= read -r -d $'\0' l_file; do
        if [ -e "$l_file" ]; then
            while IFS=: read -r l_user l_group; do
                [ "$l_user" = "UNKNOWN" ] && a_nouser+=("$l_file")   # Füge unbesessene Dateien hinzu
                [ "$l_group" = "UNKNOWN" ] && a_nogroup+=("$l_file") # Füge ungruppierte Dateien hinzu
            done < <(stat -Lc '%U:%G' "$l_file")
        fi
    done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) \( -nouser -o -nogroup \) -print0 2> /dev/null)
done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^\/run\/user\//){print $2}')

# Überprüfe, ob unbesessene Dateien existieren
if [ ${#a_nouser[@]} -eq 0 ]; then
    l_output+="\n - Es existieren keine Dateien oder Verzeichnisse ohne Besitzer auf dem lokalen Dateisystem."
else
    l_output2+="\n - Es gibt \"${#a_nouser[@]}\" unbesessene Dateien oder Verzeichnisse auf dem System.\n - Folgende unbesessene Dateien und/oder Verzeichnisse:\n$(printf '%s\n' "${a_nouser[@]}")\n - Ende der Liste"
fi

# Überprüfe, ob ungruppierte Dateien existieren
if [ ${#a_nogroup[@]} -eq 0 ]; then
    l_output+="\n - Es existieren keine Dateien oder Verzeichnisse ohne Gruppe auf dem lokalen Dateisystem."
else
    l_output2+="\n - Es gibt \"${#a_nogroup[@]}\" ungruppierte Dateien oder Verzeichnisse auf dem System.\n - Folgende ungruppierte Dateien und/oder Verzeichnisse:\n$(printf '%s\n' "${a_nogroup[@]}")\n - Ende der Liste"
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
