#!/bin/bash

### vpn client installation

### 
### ..::alxj::.. //  kolektyw kilku.com

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Make sure four params are present (but not validating params contents)
if [ -z "$4" ]; then
	echo
	echo OpenVPN client semi-automatic deployment rev002
	echo ..::alxj::.. // kolektyw kilku.com
	echo This is VERY VERY untested yet!!!
	echo usage: setup_ovpn_client serverUser serverLocation clientName port
	echo where:
	echo serverUser - name of user with sudo privileges on server
	echo serverLocation - IP or url of your VPN server
	echo clientName - name to populate KEY_CN in key certificate, this will appear in ovpn log routing table
	echo port - port to use, must be same as on server, usually 1194, 22 will work ok too
	echo example setvpn.sh dupek myvpn.com srubka 22
	exit 1
fi


# args to vars
user=$1
server=$2
name=$3
port=$4

echo Script will be executed with following parameters:
echo user: $user 
echo server: $server 
echo name: $name 
echo port: $port



 echo STEP1: LOCAL - installing OpenVPN via apt-get... 
 
 apt-get install -y openvpn openssh-server

 echo STEP2: SERVER - generating keys, will ask for server password twice... 
	
	ssh -t $user@$server sudo /etc/openvpn/setup_client.sh $name
 
 echo STEP3: downloading files, will ask for server password... 
	
 	scp $user@$server:"/etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/easy-rsa/keys/$name.*" /etc/openvpn/  

 echo STEP4: creating client.conf... 
	


	echo "client
dev tun
proto udp
remote $server $port
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert $name.crt
key $name.key
ns-cert-type server
comp-lzo
verb 3" > /etc/openvpn/client.conf


 echo STEP5: LOCAL - restarting openvpn service... 
	/etc/init.d/openvpn restart
	