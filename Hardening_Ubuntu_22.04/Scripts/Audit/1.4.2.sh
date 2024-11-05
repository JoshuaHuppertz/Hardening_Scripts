#!/usr/bin/env bash

# Definiere das Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Definiere die Audit-Nummer
AUDIT_NUMBER="1.4.2"

# Initialisiere die Ausgabewerte
l_output=""
l_check=""

# Führe den stat-Befehl aus und erfasse die Ausgabe
stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: (%u/%U) Gid: (%g/%G)' /boot/grub/grub.cfg)

# Überprüfe, ob die Ausgabe genau den gewünschten Bedingungen entspricht
if [[ "$stat_output" == "Access: (0600/-rw-------) Uid: ( 0/ root) Gid: ( 0/ root)" ]]; then
    l_check="** PASS **: Die Bedingungen für die Berechtigungen und den Eigentümer sind erfüllt."
else
    l_check="** FAIL **: Die tatsächliche Ausgabe ist:\n$stat_output"
fi

# Kompiliere die Ausgabe
l_output+="\n- Audit: $AUDIT_NUMBER\n"
l_output+="\n- Ergebnis:\n"
l_output+=" - $l_check\n"

# Bestimme das Gesamtergebnis
if [[ "$l_check" == *"FAIL"* ]]; then
    RESULT="\n- Audit Ergebnis:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Schreibe das Ergebnis in die Datei
{
    echo -e "$RESULT"
    # Füge eine Trennlinie hinzu
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnisse zur Überprüfung in der Konsole ausgeben (kann kommentiert werden)
echo -e "$RESULT"
