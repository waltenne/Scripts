#!/bin/bash

NAMESERVICE[0]=apache2
NAMESERVICE[1]=docker

NSERVICEEXIST[0]=$(find /etc/init.d/ -name apache2 | wc -l)
NSERVICEEXIST[1]=$(find /etc/init.d/ -name docker | wc -l)

running0="active(running)"
running1="is running"
running2="start/running"
stopped="inactive(dead)"
falied0="active(exited)"
falied1="failed(Result:"
activating="activating (start)"
deactivating="deactivating (stop)"

MenuServices()
{
clear
echo -ne "How do you do?"
echo -ne "\n1. Check Status"
echo -ne "\n2. Start Services"
echo -ne "\n3. Stop  Services"
echo -ne "\n4. Return Menu"
echo -ne "\nSelect Option: " ; read -r option
	case $option in
		1) Status ;;
		2) Starting ;;
		3) Stopping ;;
		4) MenuServices ;;
		*) clear && echo -ne "Option Unkown." && sleep 1 ; MenuServices ;;
		esac
}

ServiceIsActive(){
	a=$(service "$1" status | grep 'Active:' | awk '{print $2 $3}')
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
for (( a = 0, b = 0; a < ${#NAMESERVICE[*]}, b < ${#NSERVICEEXIST[*]} ; a++, b++ )) ; do
	if [[ ${NSERVICEEXIST[b]} == "1" ]];
	then
		if [[ $(ServiceIsActive ${NAMESERVICE[a]}) == "0" ]]; then
			echo "activating - ${NAMESERVICE[a]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[a]}) == "1" ]]; then
			echo "running - ${NAMESERVICE[a]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[a]}) == "2" ]]; then
			echo "stopping - ${NAMESERVICE[a]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[a]}) == "3" ]]; then
			echo "stopped - ${NAMESERVICE[a]}"
		elif [[ $(ServiceIsActive ${NAMESERVICE[a]}) == "4" ]]; then
			echo "falied - ${NAMESERVICE[a]}"
		fi
	fi
done
sleep 3
SECONDS=5
for ((i=$SECONDS; i>=1; i--));	do
	clear
	echo -ne "\nReturn in Menu Services in $i seconds" && sleep 1.5
done
MenuServices
}

Stopping(){
clear
echo -ne "How do you do?"
echo -ne "\n1. Stop Services"
echo -ne "\n2. Return at Services Menu"
echo -ne "\nSelect Option: " ; read -r option
	case $option in
		1)
			for (( x ; x < ${#NAMESERVICE[*]}; x++ )) ; do
				stoppings=$(ServiceIsActive ${NAMESERVICE[x]})
					if [[ $stoppings == '1' ]];	then
						echo "${NAMESERVICE[x]} stopping" && service ${NAMESERVICE[x]} stop
						while :
						do
								if [[ $stoppings == '3' ]]; then
									echo "${NAMESERVICE[x]} stopped"
									sleep 1.5
									break
								fi
						done
					elif [[ $stoppings != '1' ]];	then
						echo "${NAMESERVICE[x]} maybe is stopped, check next service"
						sleep 1.5
					fi
			done
			SECONDS=5
			for ((i=$SECONDS; i>=1; i--));	do
				clear
				echo -ne "Process completed. Now return in Menu Services in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		2) 
			sleep 1
			SECONDS=5
			for ((i=$SECONDS; i>=1; i--));	do
				clear
				echo -ne "Now Return in Menu Services in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		*) clear && echo -ne "Option Unkown." && sleep 1 ; Stopping ;;
		esac
}

Starting(){
clear
echo -ne "How do you do?"
echo -ne "\n1. Start Services"
echo -ne "\n2. Return at Services Menu"
echo -ne "\nSelect Option: " ; read -r option
	case $option in
		1)
			for (( z ; z < ${#NAMESERVICE[*]}; z++ )) ; do 
				startings=$(ServiceIsActive ${NAMESERVICE[x]})
					if [[ $startings == '3' ]];	then
						echo "${NAMESERVICE[z]} starting" && service ${NAMESERVICE[z]} start
						while :
						do
								if [[ $startings == '1' ]]; then
									echo "${NAMESERVICE[z]} started"
									sleep 1.5
									break
								fi
						done
					elif [[ $startings == '1' ]];	then
						echo "${NAMESERVICE[z]} is running, check next service"
						sleep 1.5

					fi
			done
			sleep 1.5
			SECONDS=5
			for ((i=$SECONDS; i>=1; i--));	do
				clear
				echo -ne "Process completed. Return in Services Menu in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		2) 
			sleep 1
			SECONDS=5
			for ((i=$SECONDS; i>=1; i--));	do
				clear
				echo -ne "Return in Services Menu in $i seconds" && sleep 1.5
			done
			MenuServices
			;;
		*) clear && echo -ne "Option Unkown." && sleep 1 ; Starting ;;
		esac
}

MenuServices
