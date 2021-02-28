#!/bin/bash

wget https://raw.githubusercontent.com/t4nputr1/aswcooooeg/main/l2tp.sh && bash l2tp.sh && sleep 3 && rm -f l2tp.sh

cd /usr/bin
wget -O addvpn https://raw.githubusercontent.com/t4nputr1/aswcooooeg/main/addvpn.sh
wget -O delvpn https://raw.githubusercontent.com/t4nputr1/aswcooooeg/main/delvpn.sh
chmod +x addvpn
chmod +x delvpn
cd
