## Quick Local tunnel (netplan) using sit module

### IT IS DESIGNED FOR MY PERSONAL USE BUT MAYBE HELP YOU OUT TO SAVE TIME.

### Summerize
 - install necessary pkg`s (iproute2 netplan.io) and check the sit module
 - unmask systemd-networkd
 - creating netplan yaml file and network file to route traffic from local gateway
   
### To do:
 - add other protocle

### Error Explanation
#### If you see this error at the beginning:
 - (Error: SIT (Simple Internet Transition) module is not supported on this system. Local tunneling cannot proceed)
#### What this means:
 - This error indicates that the sit module required for local tunneling is not supported in your server’s kernel. As a result, you cannot proceed with the tunnel setup using this module on this system.
--------------------------

![image](https://github.com/user-attachments/assets/e6047385-80a7-4d73-a24e-f1042ed94398)

## TIP
### ‼️ only answer above questions and repeat as many as you desire 
### ‼️ Just be noted that interface name and local ip range should be unique. ‼️

--------------------------

### INSTRUCTION

#### 👉 Debian Base (Ubuntu & Debian) x86 & Arm64

```
bash <(curl -s https://raw.githubusercontent.com/opiran-club/quicktunnel/main/qtunnel.sh --ipv4)
```

### Feel free to contribute xoxo
---------------------------------------------------------------------------------------------------------------------------------------

### Credits
 - credited by [OPIran](https://github.com/opiran-club)

### Contacts
 - Visit Me at [OPIran-Gap](https://t.me/opiranclub)
