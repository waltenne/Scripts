#!/bin/bash

# Autor: Waltenne Carvalho
# Github: https://github.com/waltenne

YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;15m'
GREEN='\033[1;32m'
RED='\033[1;31m'
ORANGE='\033[38;5;208m'
ALERT='\033[38;5;196m'
NC='\033[0m'

ARRAY_DIR[0]="1"
ARRAY_DIR[1]="1"
ARRAY_DIR[2]="1"
ARRAY_DIR[3]="1"
ARRAY_DIR[4]="1"
ARRAY_DIR[5]="1"
ARRAY_DIR[6]="1"
ARRAY_DIR[7]="1"
ARRAY_DIR[8]="1"
ARRAY_DIR[9]="1"
ARRAY_DIR[10]="1"
ARRAY_DIR[11]="1"
ARRAY_DIR[12]="1"
ARRAY_DIR[13]="1"
ARRAY_DIR[14]="1"
ARRAY_DIR[15]="1"
ARRAY_DIR[16]="1"
ARRAY_DIR[17]="1"
ARRAY_DIR[18]="1"
ARRAY_DIR[19]="1"
clear

for (( b=0; b < ${#ARRAY_DIR[*]}; b++ )); do
	LENGTH=${#ARRAY_DIR[@]}
	LENGTH_FINAL=$(($b*100/$LENGTH))
    if [[ $LENGTH_FINAL -le '20' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${ALERT}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"
    	sleep 1.5
    elif [[ $LENGTH_FINAL -le '45' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${RED}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"	
    	sleep 1.5
    elif [[ $LENGTH_FINAL -le '60' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${ORANGE}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"
    	sleep 1.5
    elif [[ $LENGTH_FINAL -le '80' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${YELLOW}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"
    	sleep 1.5
    elif [[ $LENGTH_FINAL -le '90' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${CYAN}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"	
    	sleep 1.5
    elif [[ $LENGTH_FINAL -le '100' ]]; then
    	clear
    	echo -ne "${WHITE}Progresso: [${NC}${GREEN}$LENGTH_FINAL%${NC}/${GREEN}100%${NC}${WHITE}]${NC}"
    	sleep 1.5
    fi
done
clear
echo -ne "${WHITE}Progresso: [${GREEN}100%${NC}/${GREEN}100%${NC}]\n"
sleep 1.5
