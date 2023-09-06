
# CSGO DDOS PROTECTION LINUX

This is a guide on setting up and saving iptables rules for your source server. Follow the steps below to configure the rules and ensure they are applied at every boot. All credits go to:
https://forums.alliedmods.net/showthread.php?p=2752850


## Prerequisites
This script assumes you have administrative privileges on your system.
Ensure that the **iptables-presistent** package is installed on your system.

On debian:
```javascript
sudo apt install iptables-persistent
```



## Instructions
Open a terminal and create a new file called iptables.sh using your prefered text editor:

```
nano iptables.sh
```
In the *iptables.sh* file, copy and paste the following content:
```
#!/bin/bash

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
```

Make the script executable and run it:
```
sudo chmod +x ./iptables.sh
sudo ./iptables.sh

```

To check if the rules have been applied successfully, run the following command:
```
sudo iptables -S

```

This command will display the current iptables rules in a readable format.

To ensure the rules are applied at every boot, save them to a file by executing the following command:
```
sudo su -c 'iptables-save > /etc/iptables/rules.v4'

```
This command saves the current iptables configuration to the file /etc/iptables/rules.v4.

Finally, reboot your system to ensure that the saved rules are automatically loaded on startup:
```
sudo reboot

```
After the reboot, the iptables rules should be applied as configured.

**Note:** It is important to exercise caution when modifying iptables rules, as incorrect configurations can potentially block desired network traffic or cause unintended consequences. Make sure to test the rules thoroughly before relying on them in a production environment.
