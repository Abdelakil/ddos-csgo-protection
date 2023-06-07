
sudo iptables -N Filter-DROP
sudo iptables -N Filter-GAME

sudo iptables -A INPUT -p udp -m udp --dport 27015:27016 -m recent --update --seconds 30 --hitcount 5 --name vse --mask 255.255.255.255 --rsource -j DROP
sudo iptables -A INPUT -p udp -m udp --dport 27015:27016 -m string --hex-string "|ffffffff54|" --algo kmp --to 65535 -j Filter-GAME

sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 27015:27016 -j ACCEPT

sudo iptables -A INPUT -p udp -m udp --dport 27015:27016 -j ACCEPT
sudo iptables -A Filter-DROP -p udp -m udp -m recent --set --name vse --mask 255.255.255.255 --rsource -j DROP
sudo iptables -A Filter-GAME -p udp -m udp --sport 0:1025 -j Filter-DROP

sudo iptables -A Filter-GAME -p udp -m udp -m length --length 0:32 -j Filter-DROP
sudo iptables -A Filter-GAME -p udp -m udp -m length --length 2521:65535 -j Filter-DROP
sudo iptables -A Filter-GAME -p udp -m udp -m length --length 60 -j Filter-DROP
sudo iptables -A Filter-GAME -p udp -m udp -m length --length 46 -j Filter-DROP


sudo iptables -A Filter-GAME -p udp -m udp -m hashlimit --hashlimit-above 1/sec --hashlimit-burst 3 --hashlimit-mode srcip,dstip,dstport --hashlimit-name StopDoS --hashlimit-htable-expire 30000 -j Filter-DROP

sudo iptables -A Filter-GAME -p udp -m udp -j RETURN
