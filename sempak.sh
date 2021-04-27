#!/bin/bash
clear

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');

#install OpenVPN
apt install openvpn easy-rsa -y
apt install openssl iptables iptables-persistent -y 
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys
cp /etc/openvpn/easy-rsa/vars.example /etc/openvpn/easy-rsa/vars

# ganti bits
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="ID"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="Jawa Tengah"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="Blora"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="Sshinjector.net"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="cs@sshinjector.net"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU="MyOrganizationalUnit"|export KEY_OU="Best Free SSH dan VPN Service"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_NAME="EasyRSA"|export KEY_NAME="server"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU=Sshinjector.net|' /etc/openvpn/easy-rsa/vars

# Create Diffie-Helman Pem
openssl dhparam -out /etc/openvpn/dh2048.pem 2048

# Create PKI
cd /etc/openvpn/easy-rsa
cp openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*

# Create key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server

# Setting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
cd
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/ca.crt
chmod +x /etc/openvpn/ca.crt

# Setting Server
cat > /etc/openvpn/tcp.conf <<-END
port 5500
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
client-cert-not-required
username-as-common-name
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
server 10.6.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
duplicate-cn
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-tcp.log
log openvpn.log
verb 3
cipher AES-128-CBC
END

cat > /etc/openvpn/ssl.conf <<-END
port 9900
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
client-cert-not-required
username-as-common-name
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
server 10.7.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
duplicate-cn
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-tcp.log
log openvpn.log
verb 3
cipher AES-128-CBC
END

cat > /etc/openvpn/udp.conf <<-END
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
client-cert-not-required
username-as-common-name
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
duplicate-cn
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-udp.log
log openvpn.log
verb 3
cipher AES-128-CBC
END

# etc
cat > /home/vps/public_html/tcp-client.ovpn <<END
# OpenVPN Configuration Dibuat Oleh Sshinjector.net
# (Contact Bussines: M Fauzan Romandhoni - m.fauzan58@yahoo.com)

client
dev tun
proto tcp
persist-key
persist-tun
dev tun
pull
resolv-retry infinite
nobind
user nobody
group nogroup
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
setenv opt block-outside-dns
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
route-delay 2
remote $MYIP 5500
cipher AES-128-CBC
END

echo '<ca>' >> /home/vps/public_html/tcp-client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/tcp-client.ovpn
echo '</ca>' >> /home/vps/public_html/tcp-client.ovpn

cat > /home/vps/public_html/ssl-client.ovpn <<END
# OpenVPN Configuration Dibuat Oleh Sshinjector.net
# (Contact Bussines: M Fauzan Romandhoni - m.fauzan58@yahoo.com)

client
dev tun
proto tcp
persist-key
persist-tun
dev tun
pull
resolv-retry infinite
nobind
user nobody
group nogroup
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
setenv opt block-outside-dns
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
route-delay 2
remote $MYIP 9900
cipher AES-128-CBC
END

echo '<ca>' >> /home/vps/public_html/ssl-client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/ssl-client.ovpn
echo '</ca>' >> /home/vps/public_html/ssl-client.ovpn

cat > /home/vps/public_html/udp-client.ovpn <<END
# OpenVPN Configuration Dibuat Oleh Sshinjector.net
# (Contact Bussines: M Fauzan Romandhoni - m.fauzan58@yahoo.com)

client
dev tun
proto udp
persist-key
persist-tun
dev tun
pull
resolv-retry infinite
nobind
user nobody
group nogroup
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
setenv opt block-outside-dns
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
route-delay 2
remote $MYIP 1194
cipher AES-128-CBC
END

echo '<ca>' >> /home/vps/public_html/udp-client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/udp-client.ovpn
echo '</ca>' >> /home/vps/public_html/udp-client.ovpn

cd /home/vps/public_html/
tar -czf /home/vps/public_html/client.tar.gz tcp-client.ovpn ssl-client.ovpn udp-client.ovpn
cd

iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o $ANU -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o $ANU -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o $ANU -j MASQUERADE
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Restart service openvpn
systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

# Restore iptables
cat > /etc/network/if-up.d/iptables <<-END
iptables-restore < /etc/iptables.up.rules
iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $ANU -j SNAT --to xxxxxxxxx
END
sed -i $MYIP2 /etc/network/if-up.d/iptables
chmod +x /etc/network/if-up.d/iptables
