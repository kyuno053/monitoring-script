#! /bin/bash
#
# Ce script permet d'avoir un apperçu rapide de l'état du système sur lequel il est activé
#	il y a deux modes d'utilisation:
#		
#		type script:	Fonctionne comme un script normal , en utilisant des arguments tel que -h 
#					
#		type shell:		Fonctionne comme un Shell de commande , accessible via l'argument -s
#
#
#
#
#
#

function SysInfo() {
	echo -e "\033[31mSystem Info\033[0m"
	kernel=`uname -s`
	kernel_release=`uname -r`
	kernel_version=`uname -v`
	os=`uname -o`
	machine=`uname -m`
	hostname=`uname -n`	
	
	echo -e "\033[33mkernel :\033[0m\033[32m${kernel} \033[0m"
	echo -e "\033[33mrelease :\033[0m\033[32m${kernel_release} \033[0m"	
	echo -e "\033[33mversion :\033[0m\033[32m${kernel_version} \033[0m"
	echo -e "\033[33mOS :\033[0m\033[32m${os} \033[0m"
	echo -e "\033[33mmachine :\033[0m\033[32m${machine} \033[0m"
	echo -e "\033[33mhostname :\033[0m\033[32m${hostname} \033[0m"
}

function CurrUser(){
	curr_user=`id -un` 
	user_groups=`id -Gn`
	echo -e "\033[33mCurrent user:\033[0m\033[32m${curr_user}\033[0m\033[33m Groups:\033[0m\033[32m${user_groups}\033[0m"
}

function Init() {
	    
	os=`uname -o`
	machine=`uname -m`
	hostname=`uname -n`	
	user=`id -un`
	hour=`date +"Day:%F | Hour:%H:%M"`
	 declare -a InitArray=('Current User:' $user '|System' $machine $hostname $os '|' $hour)
	 echo -e "\033[33m${InitArray[@]}\033[0m"
	
}

function RamMonitoringDyn() {

while :
	do
	echo -e "\033[31m Real time RAM Info (Press q to exit...)\033[0m"
	
		RamMonitoring
		sleep 1
		
		read -t 0.25 -N 1 stop
	
	 if [[ $stop = "q" ]] || [[ $stop = "Q" ]]; then
				echo
		clear
		break
		
	fi
	
	clear	

done
}

function RamMonitoring() {
	echo -e "\033[31mRAM Info\033[0m"
	libretmp1=`cat /proc/meminfo | grep MemAvailable` #get memoire restante
	totaltmp1=`cat /proc/meminfo | grep MemTotal`	#get memoire totale
	libretmp2=`echo $libretmp1|cut -d':' -f2`	#traitement
	libre=`echo $libretmp2|cut -d' ' -f1`

	totaltmp2=`echo $totaltmp1|cut -d':' -f2`	
	total=`echo $totaltmp2|cut -d' ' -f1`

	tmp=$(echo "$libre/$total"|bc -l)
	used1=$(echo "1-$tmp"|bc -l)
	used2=$(echo "$used1*100"|bc -l)	#fin traitement
	usedpc=`echo $used2|cut -f1 -d\.`% #affichage %
		

	#affichage barre (shell avec 100 colonnes ou plus)		
	echo -e "\033[33m used RAM:\033[0m\033[32m${usedpc}\033[0m\n"
	columns=`tput cols` 	
	if [ $columns -ge "100" ];
		then	
			used=`echo $used2|cut -f1 -d\.`
			ramfree=$((100-$used))
			for i in `seq 1 $ramfree`
				do
				echo -e "\033[42m \033[0m\c"
			done
			for i in `seq 1 $used`
				do
				echo -e "\033[41m \033[0m\c"
			done
	fi
#affichage barre (shell avec moins de 100 colonnes)
	if [ $columns -lt "100" ];
		then
			used1=`echo $used2|cut -f1 -d\.`
			used=$(($used1/2))
			ramfree=$((50-$used))
			for i in `seq 1 $ramfree`
				do
				echo -e "\033[42m \033[0m\c"
			done
			for i in `seq 1 $used`
				do
				echo -e "\033[41m \033[0m\c"
			done
	

	fi
	echo ""
	


}

function StorageCheck() {
	echo -e "\033[31mHard Drive Storage Info\033[0m"
	
	disk=`lsblk | grep disk | cut -d' ' -f1` #récupère les noms de disk
	n=`echo $disk|grep -c " "`
	n=$(($n+1))
	
	 for i in `seq 1 $n`
		do	
			
			
			disk1=`echo $disk | cut -d' ' -f $i` # récupère le n-ième disque
				
			if [ ! -z "$disk1" ];
				
				then
								
				tmp=`df -h|grep -n $disk1`
				line=`echo $tmp|cut -d':' -f1`
				line2=$(($line-1))
				
				getpercent=`df|grep -Eo "((([0-9]{0,2})([0-9]%){1}){1})"`
				percent=`echo $getpercent|cut -d' ' -f $line2`				
				
				tempo=`lsblk /dev/$disk1| grep -Eo " ([0-9]{0,})([,]{0,1})(([0-9]{0,})([0-9][G|M|T|K]{1}){1})"` 	#récupère la liste des partitions / sous partition avec l'espace total
				storage=`echo $tempo|cut -d' ' -f1` #récupère l'espace total du disque 
				echo -e "\033[33m disk:\033[0m\033[32m${disk1}\033[0m\033[33m storage:\033[0m\033[32m${storage}\033[0m\033[33m used:\033[0m\033[32m${percent}\033[0m"
				
				

				columns=`tput cols` 	
#affichage barre (shell avec 100 colonnes ou plus)
					if [ $columns -ge "100" ];
						then	
							dataused=`echo $percent|cut -d'%' -f1`
							datafree=$((100-$dataused))
							for i in `seq 1 $datafree`
								do
								echo -e "\033[42m \033[0m\c"
							done
							for i in `seq 1 $dataused`
								do
								echo -e "\033[41m \033[0m\c"
							done
					fi
#affichage barre (shell avec moins de 100 colonnes)
					if [ $columns -lt "100" ];
						then
							dataused1=`echo $percent|cut -d'%' -f1`
							dataused=$(($dataused1/2))
							datafree=$((50-$dataused))
							for i in `seq 1 $datafree`
								do
								echo -e "\033[42m \033[0m\c"
							done
							for i in `seq 1 $dataused`
								do
								echo -e "\033[41m \033[0m\c"
							done
	

					fi
					echo ""

							
			fi
	done	
	
}

function BootLog() {
	echo -e "\033[31mBoot Log Info\033[0m"
	log=`grep -w "    " /var/log/boot.log`
	fail=`grep -w "FAIL" /var/log/boot.log`
		
	#echo -e "\033[33m${log}\033[0m"
	if [ -n "$fail" ];
		then
		echo -e "\033[33mWarning/Failure\033[0m"	
		echo -e "\033[31m${fail}\033[0m"
		else
		echo -e "\033[32mNo warning or failure detected\033[0m"	
		
	fi
	

}


function Help() {
	echo -e "\033[31m[shell mode]\033[0m\033[32mList of arguments:\033[0m"
	echo -e "\033[33m	ram: Show used RAM"
	echo -e "	dynram: Show real time RAM state"
	echo -e "	storage: Show storage state"
	echo -e "	logs: Show (if exists) boot logs warning or failure"
	echo -e "	sys: Show system info (os, kernel ..)"
	echo -e "	user: Show current user whith his groups"
	echo -e "	cmd: Allow you to write a command like the normal shell"
	echo -e "	clr: Clear the shell prompt"
	echo -e "	help: Show help"
	echo -e "	exit: Exit the script prompt\033[0m"
	echo -e "\033[31mNeed bc package to work\033[0m"
}
function Help2() {
	echo -e "\033[31m[script mode]\033[0m\033[32mList of arguments:\033[0m"
	echo -e "\033[33m	-r: Show used RAM"
	echo -e "	-t: Show in real time RAM state"
	echo -e "		-R :Show extended RAM state"
	echo -e "	-d : Show storage state"
	echo -e "		-D : Show extended storage state"
	echo -e "	-l : Show (if exists) boot logs warning or failure"
	echo -e "		-L : Show full logs"
	echo -e "	-m : Show system info (os, kernel ..)"
	echo -e "	-u : Show current user whith his groups"
	echo -e "	-s : Switch to Shell mode"
	echo -e "	-h : Show help"
	echo -e "		-H : Show entire help\033[0m"
	echo -e "\033[31mNeed bc package to work\033[0m"

}


function Shell() {

	Init
			echo -e "\033[31mFor any help , une 'help'\nEntering shell mode ...\033[0m"
			while :
				do
	
				echo -e "\n\033[33m$>\033[0m\033[32m \c"
				read arg

					case ${arg} in
		
							[rR]am)
								
								RamMonitoring
								sleep 2
								;;
							[Dd]yn[Rr]am)
								RamMonitoringDyn
								;;
							[Ss]torage)
								StorageCheck
								sleep 2	
								;;
							[lL]ogs)
								BootLog
								sleep 2
								;;
							[Ss]ys)
								SysInfo
								sleep 2
								;;
							[Uu]ser)
								CurrUser
								sleep 2
								;;

							[eE]xit)
								echo -e "\033[31mClosing shell mode ...\033[0m"						
								sleep 1
								clear
								exit
								;;
							clr)
								clear
								Init
								;;
							cmd)
								echo -e "\033[33mWrite your command:\033[0m\033[32m\c"
								read cmd
								result=eval $cmd
								echo -e "\033[33m${result}\033[0m"
								read -p "Press a key to continue..."
								;;
							help)
								Help
								read -p "Press a key to continue..."
								;;

							*)
							echo -e "\033[31mError: \033[0m\033[33m${arg}\033[0m\033[31m isn't a valid argument, use 'help' for help"
								sleep 1
							;;

		
					esac
			done

}

if [ "$#" -eq 0 ]
	then
	echo -e "\033[31mNo arguments detected, use -h for help, or -s to enter shell mode\033[0m"	
fi
	while getopts "hsrdumltDLRH" arg;
		do
			case ${arg} in
				h)
				 Help2
				;;
				s)
				Shell
				;;
				r)
				RamMonitoring
				;;
				d)
				StorageCheck
				;;
				u)
				CurrUser
				;;
				m)
				SysInfo
				;;
				l)
				BootLog
				;;
				t)
				RamMonitoringDyn
				;;
				D)
				log=`lsblk`
				echo -e "\033[33m${log}\033[0m"
				;;
				L)
				cat /var/log/boot.log
				
				;;
				R)
				free -h
				
				;;
				H)
				Help
				Help2
				;;
				*)
					echo -e "\033[31mError: \033[0m\033[33m${arg}\033[0m\033[31m isn't a valid argument, use '-h' for help"
				;;		
				
			esac

	done












