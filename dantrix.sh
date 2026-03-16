#!/bin/bash

cat << 'EOF' | sudo tee /usr/bin/dan
#!/bin/bash

# ==========================================
# Dannebrog Matrix Screensaver (Falling Down)
# Displays the binary code of the 🇩🇰 emoji
# ==========================================

# Trap Ctrl+C (SIGINT) to restore cursor and clear screen on exit
trap "tput cnorm; echo -e '\033[0m'; clear; exit" SIGINT

# Clear screen and hide cursor
clear
tput civis

# The actual UTF-8 binary sequence for the Danish Flag Emoji (🇩 + 🇰)
DANNEBROG_BIN="1111000010011111100001111010100111110000100111111000011110110000"

# ANSI Colors
RED='\033[31m'
WHITE='\033[97m' # Bright White
RESET='\033[0m'

# Get terminal dimensions
COLUMNS=$(tput cols)
LINES=$(tput lines)

# Initialize an array to track active "drops" in each column
# 0 = inactive, 1 = active
declare -a drops
for (( i=0; i<COLUMNS; i++ )); do
    drops[$i]=0
done

while true; do
    # Move cursor to top-left (0,0)
    tput cup 0 0
    
    # Scroll the screen buffer DOWN (Reverse Index)
    # This pushes existing text down to make room at the top
    tput ri

    line=""
    
    for (( i=0; i<COLUMNS; i++ )); do
        # 1. Update column state (decide whether to start/stop a drop)
        rand=$((RANDOM % 30))
        
        if [ ${drops[$i]} -eq 1 ]; then
            # If active, small chance to stop
            if [ $rand -eq 0 ]; then
                drops[$i]=0
            fi
        else
            # If inactive, small chance to start
            if [ $rand -eq 0 ]; then
                drops[$i]=1
            fi
        fi

        # 2. Draw based on state
        if [ ${drops[$i]} -eq 1 ]; then
            # Select a random bit from the binary string
            bit=${DANNEBROG_BIN:$((RANDOM % ${#DANNEBROG_BIN})):1}
            
            # Randomly choose Red or White (White is rare "glint")
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

    # Print the constructed line at the top (without a newline character at the end)
    echo -ne "${line}"
    
    # Small delay
    sleep 0.15
done

EOF

sudo chmod +x /usr/bin/dan

clear
echo 'Skriv "dan" for at starte Pauseskærmen'
echo 'Tryk "ctrl + c" for at afslutte'
sleep 10
