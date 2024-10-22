#!/bin/bash

#/Hardening
#│
#└── Hardening_Ubuntu_22.04
#    ├── Automation.sh
#    ├── Results
#    │   ├── pass.txt
#    │   └── fail.txt
#    └── Scripts
#        ├── Audit
#        └── Remediation

# Pfad zu den Härtungsskripten
HARDENING_Audit="./Scripts/Audit"
HARDENING_Remediation="./Scripts/Remediation"

# Funktion zur Anzeige des Menüs für den Härtegrad
select_hardness() {
    echo "Wähle den gewünschten Härtegrad:"
    echo "1) Härtegrad 1"
    echo "2) Härtegrad 2"
    echo "3) Beenden"
    read -p "Bitte gib die Nummer deiner Auswahl ein: " hardness_choice

    case $hardness_choice in
        1|2)
            select_mode
            ;;
        3)
            echo "Das Skript wird beendet."
            exit 0
            ;;
        *)
            echo "Ungültige Auswahl. Bitte wähle eine gültige Option."
            select_hardness
            ;;
    esac
}

# Funktion zur Anzeige des Menüs für den Modus
select_mode() {
    echo "Wähle den gewünschten Modus:"
    echo "1) Audit"
    echo "2) Remediation"
    echo "3) Zurück zum Härtegrad-Menü"
    echo "4) Beenden"
    read -p "Bitte gib die Nummer deiner Auswahl ein: " mode_choice

    case $mode_choice in
        1|2)
            execute_scripts
            ;;
        3)
            select_hardness
            ;;
        4)
            echo "Das Skript wird beendet."
            exit 0
            ;;
        *)
            echo "Ungültige Auswahl. Bitte wähle eine gültige Option."
            select_mode
            ;;
    esac
}

# Funktion zur Ausführung der Skripte basierend auf den vorherigen Auswahlen
execute_scripts() {
    case $hardness_choice in
        1)
            mkdir -p ./Results/ #&& touch ./Results/pass.txt && touch ./Results/fail.txt
            sleep 2.5
            #clear
            
            case $mode_choice in
                1)
                    echo "Audit für Härtegrad 1 ausgewählt."
                    bash "$HARDENING_Audit/1.1.1.1.sh"
                    bash "$HARDENING_Audit/1.1.1.2.sh"
                    ;;
                2)
                    echo "Remediation für Härtegrad 1 ausgewählt."
                    ;;
            esac
            ;;
        2)
            mkdir -p ./Results/Hardening_2
            sleep 2.5
            clear
            
            case $mode_choice in
                1)
                    echo "Audit für Härtegrad 2 ausgewählt."
                    ;;
                2)
                    echo "Remediation für Härtegrad 2 ausgewählt."
                    ;;
            esac
            ;;
    esac

    echo "Das ausgewählte Skript wurde ausgeführt."
}
select_hardness
