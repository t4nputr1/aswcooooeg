#!/bin/bash

clear
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
NUMBER_OF_CLIENTS=$(grep -c -E "^" "/root/l2tpakun.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "Anda belum memiliki akun!"
		exit 1
	fi

	echo ""
	echo "Pilih Password yg akan di hapus"
	
	grep -E "^" "/root/l2tpakun.conf" | cut -d ' ' -f 1-2 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Pilih salah satu[1]: " CLIENT_NUMBER
		else
			read -rp "Pilih salah satu [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
	# match the selected number to a client name
	VPN_USER=$(grep -E "^" "/root/l2tpakun.conf" | cut -d ' ' -f 1 | sed -n "${CLIENT_NUMBER}"p)
	user=$(grep -E "^" "/root/l2tpakun.conf" | cut -d ' ' -f 1-2 | sed -n "${CLIENT_NUMBER}"p)

clear

cat <<EOF
================================================
VPN user to delete:
Username: $VPN_USER
================================================
EOF


echo "Deleting VPN user..."

# Delete VPN user
sed -i "/^\"$VPN_USER\" /d" /etc/ppp/chap-secrets
# shellcheck disable=SC2016
sed -i '/^'"$VPN_USER"':\$1\$/d' /etc/ipsec.d/passwd
sed -i "/^$user\$/,/^$/d" /root/l2tpakun.conf
# Update file attributes
chmod 600 /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*

cat <<'EOF'
Done!
EOF
