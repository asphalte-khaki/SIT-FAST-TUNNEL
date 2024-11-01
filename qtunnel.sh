#!/bin/bash
CYAN="\e[96m"
GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"
BLUE="\e[94m"
MAGENTA="\e[95m"
WHITE="\e[97m"
NC="\e[0m"
BOLD=$(tput bold)
clear
logo1="     ______    _______    __      _______        __      _____  ___   "
logo2="    /      \  |   __  \  |  \    /       \      /  \     \    \|   \  "
logo3="   /  ____  \ (  |__)  ) |   |  |         |    /    \    |.\   \    | "
logo4="  /  /    )  )|   ____/  |   |  |_____/   )   /' /\  \   |: \   \   | "
logo5=" (  (____/  / (   /      |.  |   //      /   //  __'  \  |.  \    \.| "
logo6="  \        / /    \      /\  |\ |:  __   \  /   /  \\   \ |    \    \| "
logo7="   \_____/ (_______)    (__\_|_)|__|  \___)(___/    \___)\___|\____\) "
logo() {
echo -e "${BLUE}${logo1:0:24}${RED}${logo1:24:19}${WHITE}${logo1:43:14}${GREEN}${logo1:57}${NC}"
echo -e "${BLUE}${logo2:0:24}${RED}${logo2:24:19}${WHITE}${logo2:43:14}${GREEN}${logo2:57}${NC}"
echo -e "${BLUE}${logo3:0:24}${RED}${logo3:24:19}${WHITE}${logo3:43:14}${GREEN}${logo3:57}${NC}"
echo -e "${BLUE}${logo4:0:24}${RED}${logo4:24:19}${WHITE}${logo4:43:14}${GREEN}${logo4:57}${NC}"
echo -e "${BLUE}${logo5:0:24}${RED}${logo5:24:19}${WHITE}${logo5:43:14}${GREEN}${logo5:57}${NC}"
echo -e "${BLUE}${logo6:0:24}${RED}${logo6:24:19}${WHITE}${logo6:43:14}${GREEN}${logo6:57}${NC}"
echo -e "${BLUE}${logo7:0:24}${RED}${logo7:24:19}${WHITE}${logo7:43:14}${GREEN}${logo7:57}${NC}"
}
compare_ipv6_range() {
  local ipv6_1="$1"
  local ipv6_2="$2"
  local range_1="${ipv6_1%::*}"
  local range_2="${ipv6_2%::*}"
  if [[ "$range_1" == "$range_2" && "${ipv6_1##*:}" != "${ipv6_2##*:}" ]]; then
    return 0
  else
    return 1
  fi
}
modprobe sit && apt-get install -y iproute2 netplan.io jq && systemctl unmask systemd-networkd && systemctl enable systemd-networkd && systemctl start systemd-networkd
content=$(curl -s "http://ipwho.is" || true)
public_ip=$(echo "$content" | jq -r .ip)
clear
logo
echo ""
echo -e "\e[93m+-------------------------------------+\e[0m"
echo ""
validate_ipv4() {
  [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}
validate_ipv6() {
  [[ $1 =~ ^([a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}$|([a-fA-F0-9]{1,4}:){1,7}:|([a-fA-F0-9]{1,4}:){1,6}:[a-fA-F0-9]{1,4}$ ]]
}
validate_name() {
  [[ $1 =~ ^[a-zA-Z0-9_-]+$ ]]
}
echo -ne "$YELLOW Enter desired tunnel name (e.g., tun0 or farzad) $NC"
read mytunnel && echo && echo
while ! validate_name "$mytunnel"; do
  echo -e "${RED}Invalid name. Only alphanumeric characters, underscores, and dashes are allowed.${NC}"
  echo -ne "$YELLOW Enter desired tunnel name (e.g., tun0 or farzad) $NC"
  read mytunnel && echo && echo
done
echo -ne "$YELLOW Enter current server IPv4 address [$GREEN $public_ip $YELLOW]: $NC"
read ipv4
ipv4=${ipv4:-$public_ip}
while ! validate_ipv4 "$ipv4"; do
  echo -e "${RED}Invalid IPv4 address. Please try again.${NC}" && echo
  echo -ne "$YELLOW Enter current server IPv4 address: $NC"
  read ipv4
done
echo -e "$CYAN Selected IPv4: $GREEN $ipv4 $NC" && echo && echo
echo -ne "$YELLOW Enter the current (local) IPv6 private range (e.g., 2001:db8:85a3:1b2e::1 or 2002:db8:85a3:1b2e::1 , ...) $NC"
read local_ipv6 && echo && echo
while ! validate_ipv6 "$local_ipv6"; do
  echo -e "${RED}Invalid IPv6 address. Please try again.${NC}"
  echo -ne "$YELLOW Enter the local IPv6 private range: $NC"
  read local_ipv6 && echo && echo
done
echo -ne "$YELLOW Enter the gateway (remote) IPv6 private address (e.g., 2001:db8:85a3:1b2e::2 or 2002:db8:85a3:1b2e::2 , ...) $NC"
read gateway && echo && echo
while ! validate_ipv6 "$gateway"; do
  echo -e "${RED}Invalid IPv6 address. Please try again.${NC}" && echo
  echo -ne "$YELLOW Enter the gateway (remote) IPv6 private address: $NC"
  read gateway && echo && echo
done
if ! compare_ipv6_range "$local_ipv6" "$gateway"; then
  echo -e "${RED}Error: The local and gateway IPv6 addresses must be in the same range but with different final segments.${NC}"
  exit 1
fi
echo -ne "$YELLOW Enter the remote (public) IPv4 address (e.g., 203.0.113.1) $NC"
read endpoint_ip && echo && echo
while ! validate_ipv4 "$endpoint_ip"; do
  echo -e "${RED}Invalid IPv4 address. Please try again.${NC}" && echo
  echo -ne "$YELLOW Enter the remote (public) IPv4 address: $NC"
  read endpoint_ip && echo && echo
done
netplan_file="/etc/netplan/$mytunnel.yaml"
networkd_file="/etc/systemd/network/$mytunnel.network"
if [[ -e "$netplan_file" || -e "$networkd_file" ]]; then
  echo -e "${RED}Configuration files for this tunnel name already exist. Exiting to prevent overwrite.${NC}" && echo
  exit 1
fi
echo && echo -e "${MAGENTA}networkd file. $NC"
cat <<EOF | tee "$networkd_file"
[Match]
Name=$mytunnel

[Network]
Address=$local_ipv6/64
Gateway=$gateway
EOF
echo && systemctl restart systemd-networkd
echo -e "${MAGENTA}Netplan yaml file. $NC"
cat <<EOF | tee "$netplan_file"
network:
  version: 2
  tunnels:
    $mytunnel:
      mode: sit
      local: $ipv4
      remote: $endpoint_ip
      addresses:
        - $local_ipv6/64
      mtu: 1280
EOF
sleep 2
netplan apply
echo -e "${GREEN}Configuration applied successfully.${NC}"
echo && echo
printf "               ${RED}%s ${NC}\n" "SUMMARY"
echo
printf "\e[93m+-------------------------------------+\e[0m\n" 
echo
echo -e "$CYAN Tunnel interface name: $GREEN $mytunnel $NC"
echo
echo -e "$CYAN Local IPv6 address:$GREEN  $local_ipv6 $NC"
echo -e "$CYAN Remote IPv6 address: $GREEN $gateway $NC"
echo -e "$CYAN Remote IPv4 address: $GREEN $endpoint_ip $NC"
echo
echo -e "$CYAN MTU: $GREEN 1280 $NC"
echo -e "$CYAN Protocol: $GREEN SIT $NC"
echo
printf "\e[93m+-------------------------------------+\e[0m\n"
echo && echo
echo -e "$GREEN Configuration complete. Tunnel is up and will be alive after reboot. $NC"
echo
echo -e "\n${RED}Press Enter to continue...${NC}"
read -r
