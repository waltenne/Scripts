#!/bin/bash

NAMESERVICE[0]=activemq
NAMESERVICE[1]=tomcat

NSERVICEEXIST[0]=`ls /etc/init.d/ | grep -m1 'activemq' | wc -l`
NSERVICEEXIST[1]=`ls /etc/init.d/ | grep -m1 'tomcat' | wc -l`

running0="active(running)"
running1="is running"
running2="start/running"
stopped="inactive(dead)"
falied0="active(exited)"
falied1="failed(Result:"
activating="activating (start)"
deactivating="deactivating (stop)"

MenuServicos()
{
clear
echo -ne "How do you do?"
echo -ne "\n1. Check Status"
echo -ne "\n2. Start Services"
echo -ne "\n3. Stop  Services"
echo -ne "\n4. Return Menu"
echo -ne "\nSelect Option: " ; read opcao
	case $opcao in
		1) Status ;;
		2) Starting ;;
		3) Stopping ;;
		4) MenuServices ;;
		*) 2> /dev/null; echo -e "${WHITE}Option Unkown.${NC}" ; Status ;;
		esac
}

ServiceIsActive(){
	a=`service $1 status | grep 'Active:' | awk '{print $2 $3}'`
	if [[ "$a" == "$activating" ]]; then
			echo "0"
	elif [[ "$a" == "$running0" ]] || [[ "$a" == "$running1" ]] || [[ "$a" == "$running2" ]]; then
			echo "1"
	elif [[ "$a" == "$deactivating" ]]; then
			echo "2"
	elif [[ "$a" == "$stopped" ]]; then
			echo "3"
	elif [[ "$a" == "$falied0" ]] || [[ "$a" == "$falied1" ]]; then
			echo "4"
	fi
}

Status(){
	clear
	for (( x ; x < ${#NAMESERVICE[*]}; x++ )) ; do
		if [[ $(ServiceIsActive ${NAMESERVICE[x]}) == "0" ]]; then
				echo "activating - ${NAMESERVICE[x]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) == "1" ]]; then
				echo "running - ${NAMESERVICE[x]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) == "2" ]]; then
				echo "stopping - ${NAMESERVICE[x]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) == "3" ]]; then
				echo "stopped - ${NAMESERVICE[x]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) == "4" ]]; then
				echo "falied - ${NAMESERVICE[x]}"
		fi		
	done
	sleep 3
	SECONDS=5
	for ((i=SECONDS; i>=1; i--));	do
		clear
		echo -ne "Return in Menu Services in $i seconds" && sleep 1.5
	done
	MenuServices
}

Stopping(){
clear
echo -ne "How do you do?"
echo -ne "\n1. Stop Services"
echo -ne "\n2. Return at Services Menu"
echo -ne "\nSelect Option: " ; read option
	case $option in
		1)
			for (( x ; x < ${#NAMESERVICE[*]}; x++ )) ; do 
					if [[ $(ServiceIsActive ${NAMESERVICE[x]}) == '1' ]];	then
						echo "${NAMESERVICE[x]} stopping" && service ${NAMESERVICE[x]} stop
						while :
						do
								if [[ $(ServiceIsActive ${NAMESERVICE[x]}) == '3' ]]; then
									echo "${NAMESERVICE[x]} stopped"
									break
								fi
						done
					elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) != '1' ]];	then
						echo "${NAMESERVICE[x]} maybe is stopped, check next service"
						sleep 1.5
					fi
			done
			SECONDS=5
			for ((i=SECONDS; i>=1; i--));	do
				clear
				echo -ne "Process completed. Now return in Menu Services in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		2) 
			sleep 1
			SECONDS=5
			for ((i=SECONDS; i>=1; i--));	do
				clear
				echo -ne "Now Return in Menu Services in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		*) 2> /dev/null; echo -e "${WHITE}Option Unkown.${NC}" ; Status ;;
		esac
}

Starting(){
clear
echo -ne "How do you do?"
echo -ne "\n1. Start Services"
echo -ne "\n2. Return at Services Menu"
echo -ne "\nSelect Option: " ; read option
	case $option in
		1)
			for (( x ; x < ${#NAMESERVICE[*]}; x++ )) ; do 
					if [[ $(ServiceIsActive ${NAMESERVICE[x]}) == '3' ]];	then
						echo "${NAMESERVICE[x]} starting" && service ${NAMESERVICE[x]} start
						while :
						do
								if [[ $(ServiceIsActive ${NAMESERVICE[x]}) == '1' ]]; then
									echo "${NAMESERVICE[x]} started"
									break
								fi
						done
					elif [[ $(ServiceIsActive ${NAMESERVICE[x]}) == '1' ]];	then
						echo "${NAMESERVICE[x]} is running, check next service"
						sleep 1.5
					fi
			done
			SECONDS=5
			for ((i=SECONDS; i>=1; i--));	do
				clear
				echo -ne "Process completed. Return in Services Menu in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		2) 
			sleep 1
			SECONDS=5
			for ((i=SECONDS; i>=1; i--));	do
				clear
				echo -ne "Return in Services Menu in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		*) 2> /dev/null; echo -e "${WHITE}Option Unkown.${NC}" ; Status ;;
		esac
}

MenuServices
