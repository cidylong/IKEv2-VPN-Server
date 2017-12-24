# IKEv2 VPN Server
A semi-automated shell installation script for IKEv2 VPN server.

## Introduction
A VPN (Virtual Private Network) server can serve several purposes. Conventionally used within organisations to restrict traffic from external clients through a single authenticated entry point, VPNs also serve to encrypt traffic between client and server. More recently, VPNs have gained notoriety in providing encrypted tunnels to mask traffic and bypass geographical filters/blocking.

This script will install the open source StrongSwan server, using password based EAP authentication with the addition of the free Let's Encrypt SSL certificates.

### Why IKEv2?
There are numerous protocols that VPNs can use (such as IKEv2, OpenVPN, PPTP), here is a quick summary of the main protocols.

Protocol Name |       Use     |     Reason
------------- | ------------- | -------------
PPTP | No | Compromised by the National Security Agency (NSA).
L2TP/IPSec | No | Might be compromised by the National Security Agency (NSA).
SSTP | No | Windows Only.
OpenVPN | Yes | Widely used, however third party clients required.
IKEv2 | Yes | Secure, supporting wide variety of cipher suites and has support to keep tunnels open during network switches (e.g. Wifi to 3/4G.) Not fully supported natively by all systems.

As IKEv2 becomes more widely supported the remaining few systems (i.e. Android) should begin to add native support. Until then, third party applications are available to support protocol.

Further improvements and fixes are welcomed via pull requests.

## Installation
To run a scrip the following process should be followed:
1. Ensure Port 443 is allowed through your firewall.

2. Install wget on your server.
```
For CentOS 7:
  yum install -y wget
```
3. Use wget to download script for your OS.
```
For CentOS 7:
  wget https://raw.githubusercontent.com/ScottHorner/IKEv2-VPN-Server/master/Linux/CentOS-7.sh
```
3. Grant script required permissions.
```
For CentOS 7:
  chmod u+x CentOS-7.sh
```
4. Run script and follow instructions.
```
For CentOS 7:
  ./CentOS-7.sh
```
5. Configure users.
```
For CentOS 7:
  vi /etc/strongswan/ipsec.secrets
  
  And enter to the following:
  # ipsec.secrets - strongSwan IPsec secrets file

  : RSA privkey.pem

  # VPN Users
  <USERNAME> : EAP "<PLAIN TEXT PASSWORD>"
  
  After saving and exiting the file, type strongswan rereadsecrets
```

## Supported Platforms
- [x] CentOS 7
- [ ] Ubuntu *(Planned)*

*I have personally tested the scripts on a locally hosted virtual machine of the operating system. However, slight differences may occur in live production environments. If an error occurs, please raise an issue with as much detail as possible .*


## Donate
In my spare time, I develop these scripts. If you find any useful, or want to help buy me a coffee, donations are welcome at the following Bitcoin Address:
```
165wpnX1Tfd7BJMJWtX4TqUh28wtUK3ZaT
```
