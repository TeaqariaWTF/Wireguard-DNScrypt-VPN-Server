# Wireguard-DNScrypt-VPN-Server  x86 / arm64

### Version 2021.07.24
major changes : 
 - option to edit your ip and port settings 
 - removed Debian support
 - only Ubuntu 18.04 and 20.04 support 

## **Setup Wireguard VPN Server fast and easy  - with ** 
* DNScrypt with anonymized_dns / DNSSEC (unbound)
* Ad-, Maleware-, ..., Blocking
* 3 config files  for your clients
* add or remove clients with add_client.sh / remove_client.sh 

## How to install :  
* Use a fresh / clean **server** os  ( e.g. Ubuntu 20.04 is tested ) 
* Copy the lines for your system below, and run it and follow the instructions  
* My script base_setup.sh need to installed -> [repository](https://github.com/zzzkeil/base_setups)  
   * if not installed, base_setup.sh will downloaded for you, just follow the instructions.  

----------------------------------------

###### Server x86 - Ubuntu 20.04 , 18.04 :
```

is currently in maintenance - Date 2021-07-24 - 

wget -O  wireguard-dnscrypt_blocklist_x86.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/ubuntu/wireguard-dnscrypt_blocklist_x86.sh
chmod +x wireguard-dnscrypt_blocklist_x86.sh
./wireguard-dnscrypt_blocklist_x86.sh
```


@ the end you see the QR Code for your wiregaurd app.
<details>
  <summary>example: click to expand!</summary>

[![example](https://wp.zeroaim.de/img/wgexsqr.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)
</details>
-----------------------------------------





###### Server arm64 - Ubuntu 20.04 (status: not finished) :
<details>
  <summary>Click to expand!</summary>
  
```
(testing on a pi 4 on my home network)

is currently in maintenance - Date 2021-07-24 - 

```
 </details>
-----------------------------------------

## How to add or remove clients :
```
run ./add_client.sh or ./remove_client.sh
```


## How to backup or restore settings :
```
run ./wg_config_backup.sh or ./wg_config_restore.sh
```
-----------------------------------------
