#!/usr/bin/env bash

# Verzeichnisse für die Ergebnisse festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Definiere die Auditnummer
AUDIT_NUMBER="5.4.2.5"

# Berechtigungsmaske und erwartete maximale Berechtigungen
l_output2=""
l_pmask="0022"
l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"

# Holen des root PATHs
l_root_path="$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)"

# Split PATH in ein Array aufteilen
unset a_path_loc && IFS=":" read -ra a_path_loc <<< "$l_root_path"

# Überprüfungen für bestimmte PATH-Fehler
grep -q "::" <<< "$l_root_path" && l_output2="$l_output2\n - root's path enthält ein leeres Verzeichnis (::)"
grep -Pq ":\h*$" <<< "$l_root_path" && l_output2="$l_output2\n - root's path hat ein abschließendes (:)"
grep -Pq '(\h+|:)\.(:|\h*$)' <<< "$l_root_path" && l_output2="$l_output2\n - root's path enthält das aktuelle Verzeichnis (.)"

# Überprüfung jedes Verzeichnisses im PATH
while read -r l_path; do
    if [ -d "$l_path" ]; then
        # Dateiberechtigungen und Besitzer des Verzeichnisses überprüfen
        while read -r l_fmode l_fown; do
            [ "$l_fown" != "root" ] && l_output2="$l_output2\n - Verzeichnis: \"$l_path\" gehört \"$l_fown\", sollte jedoch root gehören"
            [ $(( $l_fmode & $l_pmask )) -gt 0 ] && l_output2="$l_output2\n - Verzeichnis: \"$l_path\" hat Modus: \"$l_fmode\", sollte \"$l_maxperm\" oder restriktiver sein"
        done <<< "$(stat -Lc '%#a %U' "$l_path")"
    else
        l_output2="$l_output2\n - \"$l_path\" ist kein Verzeichnis"
    fi
done <<< "$(printf "%s\n" "${a_path_loc[@]}")"

# Ausgabe des Ergebnisses je nach Prüfungsergebnis
RESULT=""
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - Root's PATH ist korrekt konfiguriert.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ausgabe des Ergebnisses in der Konsole
echo -e "$RESULT"
