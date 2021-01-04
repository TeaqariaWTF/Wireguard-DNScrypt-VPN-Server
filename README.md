# Wireguard-DNScrypt-VPN-Server

### New Version 2021.01.04 running / testing
#### major changes : update to dnscrypt 2.0.45 with blocked_names 
#### ( take a look here : https://github.com/DNSCrypt/dnscrypt-proxy/releases/tag/2.0.45 )

## In under 5 minutes* with just a few klicks
### Setup Wireguard VPN Server,
#### incl. ipv4 and ipv6
#### incl. DNScrypt / DNSSEC (unbound)
#### incl. Ad-, Maleware-, ..., Blocking
#### incl. 5 ready client config files  ( one with QR-Code in terminal )
##### add_client.sh / remove_client.sh under development in tools

## How to install :
#### the server has to be prepared with my script base_setup.sh
##### if the base is not installed, the script below will download this one for you.
----------------------------------------

###### For Ubuntu 20.04 (server x86) :
```
wget -O  wireguard-dkms_dnscrypt_blocklist.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dkms_dnscrypt_blocklist_x86.sh

chmod +x wireguard-dkms_dnscrypt_blocklist_x86.sh

./wireguard-dkms_dnscrypt_blocklist_x86.sh
```

###### For Ubuntu 20.04 (server arm64) :
```
coming soon.....

```
-----------------------------------------

## How to add or remove clients :
```
run ./add_client.sh or remove_client.sh
```

@ the end you see the QR Code for your wiregaurd app.
example:
[![example](https://zeroaim.de/img/wgexsqr.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)

-----------------------------------------





( *less then 5 minutes on my v-server together with base_setup.sh ) 
