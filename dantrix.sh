#!/usr/bin/env bash

# ==========================================
# Dantrix Installationsscript
# Understøtter Termux og standard Linux
# ==========================================

# 1. Bestem den korrekte installationssti
if [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
    # Vi er i et Termux-miljø (Android)
    BIN_DIR="$PREFIX/bin"
    USE_SUDO=false
else
    # Vi er på standard Linux (Ubuntu, Fedora, Arch, Debian, etc.)
    # /usr/local/bin er standarden for brugerinstallerede scripts
    BIN_DIR="/usr/local/bin"
    USE_SUDO=true
fi

DEST_FILE="$BIN_DIR/dan"

echo "Installerer Dantrix til $DEST_FILE..."

# 2. Funktion der indeholder selve matrix-koden
generate_dantrix() {
    cat << 'EOF'
#!/usr/bin/env bash

# ==========================================
# Dannebrog Matrix Pauseskærm
# Viser binær kode for 🇩🇰 emojien
# ==========================================

# Fang Ctrl+C (SIGINT) for at gendanne markør og rydde skærmen
trap "tput cnorm; echo -e '\033[0m'; clear; exit" SIGINT SIGTERM

# Håndter ændring af terminalstørrelse (når vinduet trækkes større/mindre)
trap "update_dimensions" SIGWINCH

# Ryd skærm og skjul markør
clear
tput civis

# Det faktiske UTF-8 binære mønster for det danske flag emoji (🇩 + 🇰)
DANNEBROG_BIN="1111000010011111100001111010100111110000100111111000011110110000"

# ANSI Farver
RED='\033[31m'
WHITE='\033[97m' # Lys hvid
RESET='\033[0m'

declare -a drops

# Funktion til at opdatere arrayet, hvis skærmen ændrer størrelse
update_dimensions() {
    COLUMNS=$(tput cols)
    LINES=$(tput lines)
    
    # Sørg for at arrayet dækker alle kolonner (hvis skærmen blev bredere)
    for (( i=0; i<COLUMNS; i++ )); do
        if [ -z "${drops[$i]}" ]; then
            drops[$i]=0
        fi
    done
    clear
}

# Initialiser dimensioner ved opstart
update_dimensions

while true; do
    # Flyt markør til øverste venstre hjørne (0,0)
    tput cup 0 0
    
    # Rul skærmbufferen NED (Reverse Index)
    # Dette skubber eksisterende tekst ned for at gøre plads i toppen
    tput ri

    line=""
    
    for (( i=0; i<COLUMNS; i++ )); do
        # 1. Opdater kolonnetilstand (beslut om en "dråbe" skal starte/stoppe)
        rand=$((RANDOM % 30))
        
        if [ ${drops[$i]} -eq 1 ]; then
            # Hvis aktiv, lille chance for at stoppe
            if [ $rand -eq 0 ]; then
                drops[$i]=0
            fi
        else
            # Hvis inaktiv, lille chance for at starte
            if [ $rand -eq 0 ]; then
                drops[$i]=1
            fi
        fi

        # 2. Tegn baseret på tilstand
        if [ ${drops[$i]} -eq 1 ]; then
            # Vælg en tilfældig bit fra den binære streng
            bit=${DANNEBROG_BIN:$((RANDOM % ${#DANNEBROG_BIN})):1}
            
            # Vælg tilfældigt Rød eller Hvid (Hvid er sjældent glimt)
            color_rand=$((RANDOM % 10))
            if [ $color_rand -gt 8 ]; then
                line+="${WHITE}${bit}"
            else
                line+="${RED}${bit}"
            fi
        else
            line+=" "
        fi
    done

    # Udskriv den konstruerede linje i toppen (uden linjeskift til sidst)
    echo -ne "${line}"
    
    # Lille pause for at styre hastigheden
    sleep 0.15
done
EOF
}

# 3. Skriv filen (med eller uden sudo afhængigt af miljøet)
if [ "$USE_SUDO" = true ]; then
    if command -v sudo >/dev/null 2>&1; then
        # Sørg for at mappen findes (vigtigt på nogle minimale distros som Fedora Server)
        sudo mkdir -p "$BIN_DIR"
        generate_dantrix | sudo tee "$DEST_FILE" > /dev/null
        sudo chmod +x "$DEST_FILE"
    else
        echo "Fejl: 'sudo' blev ikke fundet, og er påkrævet for at installere i $BIN_DIR."
        exit 1
    fi
else
    # Til Termux og systemer hvor brugeren har skriverettigheder
    generate_dantrix > "$DEST_FILE"
    chmod +x "$DEST_FILE"
fi

clear
echo "✅ Installation fuldført succesfuldt!"
echo "=========================================="
echo "Skriv \"dan\" for at starte Pauseskærmen"
echo "Tryk \"Ctrl + C\" for at afslutte"
echo "=========================================="
