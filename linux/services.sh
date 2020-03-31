#!/bin/bash

# Autor Waltenne Carvalho
# https://github.com/waltenne/

YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;15m'
GREEN='\033[1;32m'
RED='\033[1;31m'
ORANGE='\033[38;5;208m'
ALERT='\033[38;5;196m'
NC='\033[0m'

RUNNING0="active(running)"
RUNNING1="is running"
RUNNING2="start/running"
STOPPED="inactive(dead)"
FALIED0="active(exited)"
FALIED1="failed(Result:"
ACTIVATING="activating (start)"
DEACTIVATING="deactivating (stop)"

NAMESERVICE[0]=activemq
NAMESERVICE[1]=tomcat

function ReturnServiceMenu(){
local SECONDS=5
for ((a=$SECONDS; a>=1; a--));	do
	clear
	echo -ne "${WHITE}Retornando ao Menu de Servicos em${NC} ${CYAN}$a${NC} ${WHITE}segundos${NC}" && sleep 1.5
done
./$(basename $0) menu && exit 
}

function ExitScript(){
local SECONDS=5
for ((a=$SECONDS; a>=1; a--));	do
	clear
	echo -ne "${WHITE}Saindo do Script em${NC} ${CYAN}$a${NC} ${WHITE}segundos${NC}" && sleep 1.5
done
exit 
}

function ServicesMenu()
{
clear
echo -ne "\t${WHITE}O que voce quer Fazer?${NC}"
echo -ne "\n${ORANGE}\t1.${NC} ${WHITE}Verificar Status${NC}"
echo -ne "\n${ORANGE}\t2.${NC} ${WHITE}Iniciar Servicos${NC}"
echo -ne "\n${ORANGE}\t3.${NC} ${WHITE}Parar Servicos${NC}"
echo -ne "\n${ORANGE}\t4.${NC} ${WHITE}Retornar ao Menu Principal${NC}"
echo -ne "\n${ORANGE}\t5.${NC} ${WHITE}Sair do Script${NC}"
echo -ne "\n${WHITE}——————————————————————————————————————————${NC}"
echo -ne "\n${WHITE}Digite uma opcao:${NC} " ; read OPTION
	case $OPTION in
		1) ./$(basename $0) status && exit ;;
		2) ./$(basename $0) iniciar && exit ;;
		3) ./$(basename $0) parar && exit ;;
		4) ReturnMainMenu ;;
		5) clear && exit ;; 
    	*) clear && echo -ne "\n${WHITE}Opcao Invalida${NC}" && sleep 1 ; ServicesMenu ;;
		esac
}

function QuestionServiceMenu(){
echo -ne "${WHITE}——————————————————————————————————————————${NC}"
echo -ne "\n\t${WHITE}O que voce quer Fazer?${NC}"
echo -ne "\n${ORANGE}\t1.${NC} ${WHITE}Verificar Status${NC}"
echo -ne "\n${ORANGE}\t2.${NC} ${WHITE}Retornar ao Menu Servicos${NC}"
echo -ne "\n${ORANGE}\t3.${NC} ${WHITE}Sair do Script${NC}"
echo -ne "\n${WHITE}——————————————————————————————————————————${NC}"
echo -ne "\n${WHITE}Digite uma opcao:${NC} " ; read OPTION
	case $OPTION in
		1) ./$(basename $0) status && exit  ;;
		2) ReturnServiceMenu ;;
		3) clear && exit ;; 
    	*) clear && echo -ne "\n${WHITE}Opcao Invalida${NC}" && sleep 1 ; QuestionServiceMenu ;;
		esac
}

function ServiceIsActive(){
local GETSTATUS=$(service "$1" status | grep 'Active:' | awk '{print $2 $3}')
if [[ "$GETSTATUS" == "$ACTIVATING" ]]; then
	echo "0"
elif [[ "$GETSTATUS" == "$RUNNING0" ]] || [[ "$GETSTATUS" == "$RUNNING1" ]] || [[ "$GETSTATUS" == "$RUNNING2" ]]; then
	echo "1"
elif [[ "$GETSTATUS" == "$DEACTIVATING" ]]; then
	echo "2"
elif [[ "$GETSTATUS" == "$STOPPED" ]]; then
	echo "3"
elif [[ "$GETSTATUS" == "$FALIED0" ]] || [[ "$GETSTATUS" == "$FALIED1" ]]; then
	echo "4"
fi
}

function GetStatus(){
local SRV_EXIST=`ls -ln /etc/init.d/ | grep "$1" | awk '{print $9}' | wc -l`
if [[ $SRV_EXIST == "1" ]];
then
	local STATUS_SRV=`ServiceIsActive "$1"`
	if [[ "$STATUS_SRV" == "0" ]]; then
		echo -ne "${GREEN}Inicializando${NC} ${WHITE}| "$1"\n"
	elif [[ "$STATUS_SRV" == "1" ]]; then
		echo -ne "${GREEN}Em Execucao  ${NC} ${WHITE}| "$1"\n"
	elif [[ "$STATUS_SRV" == "2" ]]; then
		echo -ne "${YELLOW}Parando      ${NC} ${WHITE}| "$1"\n"
	elif [[ "$STATUS_SRV" == "3" ]]; then
		echo -ne "${RED}Parado       ${NC} ${WHITE}| "$1"\n"
	elif [[ "$STATUS_SRV" == "4" ]]; then
		echo -ne "${ALERT}Falha        ${NC} ${WHITE}| "$1"\n"
	fi
fi
}

function Status(){
clear
for (( a; a < ${#NAMESERVICE[*]}; a++ )); do
	GetStatus "${NAMESERVICE[a]}"
done
QuestionServiceMenu
}

function Stopping(){
clear
echo -ne "\t${WHITE}Você está na funcao que para todos os servicos.${NC}"
echo -ne "\n\t${WHITE}Você deseja continuar?${NC}"
echo -ne "\n${ORANGE}\t1.${NC} ${WHITE}Sim${NC}"
echo -ne "\n${ORANGE}\t2.${NC} ${WHITE}Nao, volte ao Menu Servicos${NC}"
echo -ne "\n${ORANGE}\t3.${NC} ${WHITE}Sair do Script${NC}"
echo -ne "\n${WHITE}——————————————————————————————————————————${NC}"
echo -ne "\n${WHITE}Digite uma opcao:${NC} " ; read -r OPTION
	case $OPTION in
		1)
			for (( x; x < ${#NAMESERVICE[*]}; x++ ));
			do
				local SRV_EXIST=$(ls -ln /etc/init.d/ | grep -m1 "${NAMESERVICE[x]}$" | awk '{print $9}' | wc -l )
				if [[ $SRV_EXIST == '1' ]];
				then
					sleep 0.5
					local SERVICESTATUS=$(ServiceIsActive ${NAMESERVICE[x]})
					if [[ $SERVICESTATUS == '1' ]];
					then
						clear
						echo -ne "${WHITE}Parando o servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC}" && service ${NAMESERVICE[x]} stop
						sleep 1.5
						clear
						echo -ne "${WHITE}Verificando se o servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}foi parado${NC}"
						sleep 1.5
						local SERVICESTATUS2=$(ServiceIsActive ${NAMESERVICE[x]})
						if [[ $SERVICESTATUS2 == "3" ]]; 
						then
							clear
							echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}foi parado com${NC} ${GREEN}sucesso${NC}${WHITE}.${NC}"
							sleep 1.5
						elif [[ $SERVICESTATUS2 != "3" ]]; 
						then
							clear
							echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}nao foi${NC} ${ALERT}parado${NC} ${WHITE}verifique as causas${NC}${WHITE}.${NC}\n"
							sleep 1.5
						fi
					elif [[ $SERVICESTATUS == '3' ]];
					then
						clear
						echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}esta parado, nada sera feito.${NC}\n"
						sleep 1.5							
					fi
				fi
			done
			sleep 1.5
			ReturnServiceMenu;;
		2) ReturnServiceMenu ;;
		3) ExitScript ;; 
    	*) clear && echo -ne "\n${WHITE}Opcao Invalida${NC}" && sleep 1 ; StartingMain ;;
		esac
}

function Starting(){
clear
echo -ne "\t${WHITE}Você está na funcao que inicia todos os servicos.${NC}"
echo -ne "\n\t${WHITE}Você deseja continuar?${NC}"
echo -ne "\n${ORANGE}\t1.${NC} ${WHITE}Sim${NC}"
echo -ne "\n${ORANGE}\t2.${NC} ${WHITE}Nao, volte ao Menu Servicos${NC}"
echo -ne "\n${ORANGE}\t3.${NC} ${WHITE}Sair do Script${NC}"
echo -ne "\n${WHITE}——————————————————————————————————————————${NC}"
echo -ne "\n${WHITE}Digite uma opcao:${NC} " ; read -r OPTION
	case $OPTION in
		1)
			for (( x; x < ${#NAMESERVICE[*]}; x++ ));
			do
				local SRV_EXIST=$(ls -ln /etc/init.d/ | grep -m1 "${NAMESERVICE[x]}$" | awk '{print $9}' | wc -l )
				if [[ $SRV_EXIST == '1' ]];
				then
					sleep 0.5
					local SERVICESTATUS=$(ServiceIsActive ${NAMESERVICE[x]})
					if [[ $SERVICESTATUS == '3' ]];
					then
						clear
						echo -ne "${WHITE}Iniciando o servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC}" && service ${NAMESERVICE[x]} start
						sleep 1.5							
						clear
						echo -ne "${WHITE}Verificando se o servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}foi iniciado${NC}"
						sleep 1.5
						local SERVICESTATUS2=$(ServiceIsActive ${NAMESERVICE[x]})
						if [[ $SERVICESTATUS2 == "1" ]]; 
						then
							clear
							echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}foi iniciado com${NC} ${GREEN}sucesso${NC}${WHITE}.${NC}"
							sleep 1.5
						elif [[ $SERVICESTATUS2 != "1" ]]; 
						then
							clear
							echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}nao foi${NC} ${ALERT}iniciado${NC} ${WHITE}verifique as causas${NC}${WHITE}.${NC}\n"
							sleep 1.5
						fi
					elif [[ $SERVICESTATUS == '1' ]];
					then
						clear
						echo -ne "${WHITE}O Servico${NC} ${YELLOW}${NAMESERVICE[x]}${NC} ${WHITE}esta iniciado, nada sera feito.${NC}\n"
						sleep 1.5
					fi
				fi
			done
			sleep 1.5
			ReturnServiceMenu;;
		2) ReturnServiceMenu ;;
		3) ExitScript ;; 
    	*) clear && echo -ne "${WHITE}Opcao Invalida${NC}" && sleep 1 ; StartingMain ;;
		esac 
}

	case "$1" in
		status)Status;;
		menu)ServicesMenu;;
		iniciar)Starting;;
		parar)Stopping;;
		*)echo -ne "${WHITE}Opcao Invalida: Utilize a opcao:${NC} ${GREEN}parar${NC}${WHITE},${NC} ${GREEN}iniciar${NC}${WHITE},${NC} ${GREEN}menu${NC}${WHITE},${NC} ${GREEN}status${NC}${WHITE}.${NC}" ;;
 	esac
