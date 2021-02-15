#!/bin/sh

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0'`;
MYIP2="s/xxxxxxxxx/$MYIP/g";

apt-get update && apt-get upgrade -y
apt-get install wget curl -y

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

cd
# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set repo
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;
apt-get -y --purge remove dropbear*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php-fpm php-mcrypt php-cli libexpat1-dev libxml-parser-perl

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# vnstat
apt-get -y install vnstat
systemctl start vnstat
systemctl enable vnstat
chkconfig vnstat on
chown -R vnstat:vnstat /var/lib/vnstat

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# install fail2ban
apt-get -y install fail2ban
service fail2ban restart
cd

# WebServer Configuration
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/Dreyannz/AutoScriptVPS/master/Files/Nginx/nginx.conf"
mkdir -p /home/vps/public_html
echo "<h1><center>AutoScriptVPS by ME</center></h1>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/Dreyannz/AutoScriptVPS/master/Files/Nginx/vps.conf"
service nginx restart


# ssh
sed -i '$ i\Banner /etc/banner.txt' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 80 -p 456 -p 777"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/banner.txt"@g' /etc/default/dropbear
service ssh restart
service dropbear restart

# install webmin
cd
apt-get -y install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
service webmin restart

# Install BadVPN
cd
wget -O /usr/bin/badvpn-udpgw "https://github.com/Dreyannz/AutoScriptVPS/raw/master/Files/BadVPN/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://github.com/Dreyannz/AutoScriptVPS/raw/master/Files/BadVPN/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# auto start badvpn single port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 100' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 --max-connections-for-client 100 &
cd

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:80
connect = 127.0.0.1:442
connect = 127.0.0.1:456
connect = 127.0.0.1:777

[openssh]
accept = 444
connect = 127.0.0.1:22

END

# detail nama perusahaan
country=ID
state=Blora
locality=Java
organization=sshinjector.net
organizationalunit=sshinjector.net
commonname=sshinjector.net
email=cs@sshinjector.net

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#Setting IPtables
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source xxxxxxxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:fail2ban-ssh - [0:0]
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-ssh
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -i eth0 -p tcp -m tcp --dport 110 -j ACCEPT
-A INPUT -i tun0 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 456  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 442  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 443  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 444  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 7300  -m state --state NEW -j ACCEPT

-A fail2ban-ssh -j RETURN
-A OUTPUT -p icmp --icmp-type echo-request -j DROP
-A INPUT -p tcp --tcp-flags ALL NONE -j DROP
-A INPUT -p tcp --tcp-flags ALL ALL -j DROP
-A INPUT -f -j DROP
-A INPUT -p tcp ! --syn -m state --state NEW -j DROP
-A INPUT -m string --string "BitTorrent" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "BitTorrent protocol" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "peer_id=" --algo bm --to 65535 -j DROP
-A INPUT -m string --string ".torrent" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "announce.php?passkey=" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "torrent" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "announce" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "info_hash" --algo bm --to 65535 -j DROP
-A INPUT -m string --string "peer_id" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "BitTorrent" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "BitTorrent protocol" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "bittorrent-announce" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "announce.php?passkey=" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "find_node" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "info_hash" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "get_peers" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "announce" --algo kmp --to 65535 -j DROP
-A INPUT -m string --string "announce_peers" --algo kmp --to 65535 -j DROP
-t nat -A POSTROUTING -o eth0 -j MASQUERADE
-I OUTPUT -p tcp --dport 1723 -j ACCEPT
-A OUTPUT -p tcp --dport 6881:6889 -j DROP
-A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
-A FORWARD -p tcp --dport 6881:6889 -j DROP
-D FORWARD -m string --algo bm --string "BitTorrent" -j LOGDROP
-D FORWARD -m string --algo bm --string "BitTorrent protocol" -j LOGDROP
-D FORWARD -m string --algo bm --string "peer_id=" -j LOGDROP
-D FORWARD -m string --algo bm --string ".torrent" -j LOGDROP
-D FORWARD -m string --algo bm --string "announce.php?passkey=" -j LOGDROP
-D FORWARD -m string --algo bm --string "torrent" -j LOGDROP
-D FORWARD -m string --algo bm --string "announce" -j LOGDROP
-D FORWARD -m string --algo bm --string "info_hash" -j LOGDROP
-A FORWARD -m string --string "get_peers" --algo bm -j DROP
-A FORWARD -m string --string "announce_peer" --algo bm -j LOGDROP
-A FORWARD -m string --string "find_node" --algo bm -j LOGDROP
-A FORWARD -p udp -m string --algo bm --string "BitTorrent" -j DROP
-A FORWARD -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP
-A FORWARD -p udp -m string --algo bm --string "peer_id=" -j DROP
-A FORWARD -p udp -m string --algo bm --string ".torrent" -j DROP
-A FORWARD -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP
-A FORWARD -p udp -m string --algo bm --string "torrent" -j DROP 
-A FORWARD -p udp -m string --algo bm --string "announce" -j DROP
-A FORWARD -p udp -m string --algo bm --string "info_hash" -j DROP 
-A FORWARD -p udp -m string --algo bm --string "tracker" -j DROP 
-A INPUT -p udp -m string --algo bm --string "BitTorrent" -j DROP 
-A INPUT -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP iptables -A INPUT -p udp -m string --algo bm --string "peer_id=" -j DROP 
-A INPUT -p udp -m string --algo bm --string ".torrent" -j DROP 
-A INPUT -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP iptables -A INPUT -p udp -m string --algo bm --string "torrent" -j DROP 
-A INPUT -p udp -m string --algo bm --string "announce" -j DROP 
-A INPUT -p udp -m string --algo bm --string "info_hash" -j DROP 
-A INPUT -p udp -m string --algo bm --string "tracker" -j DROP 
-I INPUT -p udp -m string --algo bm --string "BitTorrent" -j DROP 
-I INPUT -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP iptables -I INPUT -p udp -m string --algo bm --string "peer_id=" -j DROP 
-I INPUT -p udp -m string --algo bm --string ".torrent" -j DROP 
-I INPUT -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP iptables -I INPUT -p udp -m string --algo bm --string "torrent" -j DROP 
-I INPUT -p udp -m string --algo bm --string "announce" -j DROP
-I INPUT -p udp -m string --algo bm --string "info_hash" -j DROP 
-I INPUT -p udp -m string --algo bm --string "tracker" -j DROP 
-D INPUT -p udp -m string --algo bm --string "BitTorrent" -j DROP 
-D INPUT -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP iptables -D INPUT -p udp -m string --algo bm --string "peer_id=" -j DROP 
-D INPUT -p udp -m string --algo bm --string ".torrent" -j DROP 
-D INPUT -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP iptables -D INPUT -p udp -m string --algo bm --string "torrent" -j DROP 
-D INPUT -p udp -m string --algo bm --string "announce" -j DROP 
-D INPUT -p udp -m string --algo bm --string "info_hash" -j DROP 
-D INPUT -p udp -m string --algo bm --string "tracker" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "BitTorrent" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP iptables -I OUTPUT -p udp -m string --algo bm --string "peer_id=" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string ".torrent" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP iptables -I OUTPUT -p udp -m string --algo bm --string "torrent" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "announce" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "info_hash" -j DROP 
-I OUTPUT -p udp -m string --algo bm --string "tracker" -j DROP
-D INPUT -m string --algo bm --string "BitTorrent" -j DROP 
-D INPUT -m string --algo bm --string "BitTorrent protocol" -j DROP 
-D INPUT -m string --algo bm --string "peer_id=" -j DROP
-D INPUT -m string --algo bm --string ".torrent" -j DROP 
-D INPUT -m string --algo bm --string "announce.php?passkey=" -j DROP 
-D INPUT -m string --algo bm --string "torrent" -j DROP 
-D INPUT -m string --algo bm --string "announce" -j DROP
-D INPUT -m string --algo bm --string "info_hash" -j DROP
-D INPUT -m string --algo bm --string "tracker" -j DROP 
-D OUTPUT -m string --algo bm --string "BitTorrent" -j DROP
-D OUTPUT -m string --algo bm --string "BitTorrent protocol" -j DROP
-D OUTPUT -m string --algo bm --string "peer_id=" -j DROP
-D OUTPUT -m string --algo bm --string ".torrent" -j DROP
-D OUTPUT -m string --algo bm --string "announce.php?passkey=" -j DROP 
-D OUTPUT -m string --algo bm --string "torrent" -j DROP
-D OUTPUT -m string --algo bm --string "announce" -j DROP
-D OUTPUT -m string --algo bm --string "info_hash" -j DROP
-D OUTPUT -m string --algo bm --string "tracker" -j DROP 
-D FORWARD -m string --algo bm --string "BitTorrent" -j DROP
-D FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
-D FORWARD -m string --algo bm --string "peer_id=" -j DROP
-D FORWARD -m string --algo bm --string ".torrent" -j DROP
-D FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
-D FORWARD -m string --algo bm --string "torrent" -j DROP
-D FORWARD -m string --algo bm --string "announce" -j DROP
-D FORWARD -m string --algo bm --string "info_hash" -j DROP
-D FORWARD -m string --algo bm --string "tracker" -j DROP
COMMIT
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
END
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules

# common password debian 
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/common-password-deb9"
chmod +x /etc/pam.d/common-password

wget -O /usr/bin/add-user https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/usernew.sh
chmod +x /usr/bin/add-user

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

# Finishing
cd
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service dropbear restart
service webmin restart
rm -rf ~/.bash_history && history -c
rm -f /root/AutoScriptVPS.sh
echo "unset HISTFILE" >> /etc/profil
