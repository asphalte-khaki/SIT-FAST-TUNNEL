## Quick Local Tunnel (Netplan) Setup Using SIT Module

### Note
 - Designed for personal use but may help others save time.😊

### Summary
 1. Installs necessary packages (iproute2, netplan.io) and checks for SIT module support.
 2. Unmasks systemd-networkd for enabling tunnel management.
 3. Creates and configures Netplan and network files for local traffic routing through a defined gateway.
   
### To do:
 - Add support for other protocols.

--------------------
## TIP⚠️

![image](https://github.com/user-attachments/assets/e6047385-80a7-4d73-a24e-f1042ed94398)


 - Only answer specific questions above; repeat as needed.
 - Ensure interface names and local IP ranges are unique. 

--------------------------

### INSTRUCTION

#### For Debian-based systems (Ubuntu & Debian), x86 & Arm64:

```
bash <(curl -s https://raw.githubusercontent.com/opiran-club/quicktunnel/main/qtunnel.sh --ipv4)
```
--------------
### ‼️ Error Explanation ‼️
#### If you see this error at the beginning:
 - (Error: SIT (Simple Internet Transition) module is not supported on this system. Local tunneling cannot proceed)
#### What this means:
 - This error indicates that the sit module required for local tunneling is not supported in your server’s kernel. As a result, you cannot proceed with the tunnel setup using this module on this system.
