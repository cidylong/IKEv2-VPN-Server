#!/bin/sh

#  CentOS-7.sh - Initial server setup and security hardening script.
#
#  Created by Scott Horner.
#

function setup_functions() {
  check_root
  get_details
  update_system
  install_packages
  generate_certs
  configure_vpn
  configure_firewall
}

# Check script is ran as root
function check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "[\e[31;1mERROR\e[0m] Script must be as root!"
    exit 1
  fi
}


# Get user-specified details
function get_details() {
  echo -e "[\e[34;1mINPUT\e[0m] Enter Email Address:"
  read email_addr
  echo -e "[\e[34;1mINPUT\e[0m] Enter Hostname (Must resolve to server IP, via DNS):"
  read hostname
  echo -e "[\e[34;1mINPUT\e[0m] Enter SSH Port (To Configure Firewall):"
  read ssh_port
}


# Update system and pre-installed packages.
function update_system() {
  {
    yum update -y
    RC=$?
} &> /dev/null

if [ $RC -ne 0 ]
  then
    echo -e "[\e[31;1mERROR\e[0m] Unable to update system and pre-installed packages!"
  else
    echo -e "[\e[32;1mSUCCESS\e[0m] Updated system and pre-installed packages."
  fi
}


# Install additional required packages
function install_packages() {
  {
    yum -y install epel-release strongswan certbot
    RC=$?
  } &> /dev/null

  if [ $RC -ne 0 ]
    then
    echo -e "[\e[31;1mERROR\e[0m] Unable to install additional packages!"
  else
    echo -e "[\e[32;1mSUCCESS\e[0m] Installed additional packages."
  fi
}

# Generate SSL Certs
function generate_certs() {
  {
    certbot certonly --non-interactive --agree-tos --email $email_addr --standalone -d $hostname
    RC=$?
  } &> /dev/null

  if [ $RC -ne 0 ]
    then
    echo -e "[\e[31;1mERROR\e[0m] Unable to generate certificates!"
  else
    echo -e "[\e[32;1mSUCCESS\e[0m] Generated certificates."
    ln -s /etc/letsencrypt/live/$hostname/fullchain.pem /etc/strongswan/ipsec.d/certs/fullchain.pem
    ln -s /etc/letsencrypt/live/$hostname/privkey.pem /etc/strongswan/ipsec.d/private/privkey.pem
    ln -s /etc/letsencrypt/live/$hostname/chain.pem /etc/strongswan/ipsec.d/cacerts/chain.pem
  fi
}

# Configure Strongswan
function configure_vpn() {
  {
    rm /etc/strongswan/ipsec.conf
    wget https://raw.githubusercontent.com/ScottHorner/IKEv2-VPN-Server/master/ipsec.conf -P /etc/strongswan/
    sed -i "s/leftid=HOSTNAME/leftid=$hostname/g" /etc/strongswan/ipsec.conf
    echo '# VPN' >> /etc/sysctl.conf
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    echo 'net.ipv4.conf.all.accept_redirects = 0' >> /etc/sysctl.conf
    echo 'net.ipv4.conf.all.send_redirects = 0' >> /etc/sysctl.conf
    sysctl -p
    RC=$?
  } &> /dev/null

  if [ $RC -ne 0 ]
    then
      echo -e "[\e[31;1mERROR\e[0m] Unable to configure VPN!"
    else
      echo -e "[\e[32;1mSUCCESS\e[0m] Configured VPN."
  fi
}


# Configure Firewall
function configure_firewall() {
  {
    firewall-cmd --zone=dmz --permanent --add-rich-rule='rule protocol value="esp" accept'
    firewall-cmd --zone=dmz --permanent --add-rich-rule='rule protocol value="ah" accept'
    firewall-cmd --zone=dmz --permanent --add-port=500/udp
    firewall-cmd --zone=dmz --permanent --add-port=4500/udp
    firewall-cmd --zone=dmz --permanent --add-port=$ssh_port/tcp
    firewall-cmd --zone=dmz --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-service="ipsec"
    firewall-cmd --zone=dmz --permanent --add-masquerade
    firewall-cmd --set-default-zone=dmz
    firewall-cmd --reload
    RC=$?
  } &> /dev/null

  if [ $RC -ne 0 ]
    then
      echo -e "[\e[31;1mERROR\e[0m] Unable to configure firewall!"
    else
      echo -e "[\e[32;1mSUCCESS\e[0m] Configured firewall."
    fi
}


### PROGRAM START ###
clear
echo -e "[\e[34;1mINFOR\e[0m] HTTPS/Port 443 MUST BE ALLOWED THROUGH YOUR FIREWALL FOR CERT GENERATION!:"
setup_functions
systemctl restart strongswan
systemctl enable strongswan
echo -e "[\e[34;1mINFO\e[0m] USERS NEED TO BE ADDED! VISIT THE REPO WIKI TO ADD USERS!"
