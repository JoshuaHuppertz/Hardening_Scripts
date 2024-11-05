#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.1.1"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Funktion zur Überprüfung, ob aide und aide-common installiert sind
check_aide_installation() {
    # Überprüfen, ob aide installiert ist
    if dpkg-query -s aide &>/dev/null; then
        l_output+="\n - aide ist installiert"
    else
        l_output2+="\n - aide ist nicht installiert"
    fi

    # Überprüfen, ob aide-common installiert ist
    if dpkg-query -s aide-common &>/dev/null; then
        l_output+="\n - aide-common ist installiert"
    else
        l_output2+="\n - aide-common ist nicht installiert"
    fi
}

# Audit durchführen
check_aide_installation

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
