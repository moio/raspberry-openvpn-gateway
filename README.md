# Raspberry Pi OpenVPN sharing gateway

This project allows you to give access to a VPN tunnel through multiple machines via a [Raspberry Pi](https://www.raspberrypi.org/) (1 or 2) with two network interfaces.

Network topology follows:

```
 +--------------+
 |              |                                                                                   X XXXXXX
 |    host 1    +------+                                                                          XX        XXX
 |              |      |                                                                         X            X
 +--------------+      |                                                                       XX              XX XX XX
                       |                                                                       X                        XX
 +--------------+      |     +----------------+    eth0    +----------------+   eth1       XXXXX                         XX         +-----------------+
 |              |      +---->|                |            |                |            XXX                               X        |                 |
 |    host 2    +----------->|     switch     +----------->+  Raspberry Pi  +----------> X              Internet          XX ------>+  VPN endpoint   |
 |              |      +---->|                |            |                |            X                               XX         |                 |
 +--------------+      |     +----------------+            +----------------+             XXX     XXX                    XX         +-----------------+
                       |                                                                     XXX X  XX          X        X
 +--------------+      |                                                                             XX        XXX    XXX
 |              |      |                                                                               XXX XXXX   XXXX
 |   host 3     +------+
 |              |
 +--------------+

```

Raspberry Pi acts as router, very basic firewall, DHCP server, DNS cache and VPN endpoint. This project provides [SaltStack](http://saltstack.com/) files to configure the Pi.

## Hardware requirements

 - [Raspberry Pi 2](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/) (original Model B Raspberry Pi also works but it's limited in bandwidth);
 - [Raspberry Pi case](https://www.raspberrypi.org/products/raspberry-pi-case/);
 - USB power adapter (5v, 2000mA, 10W) with micro USB plug;
 - microSD card (4GB or more);
 - [TRENDNET TU3-ETG USB3 Gigabit Ethernet adapter](https://www.trendnet.com/products/proddetail.asp?prod=315_TU3-ETG);

## Raspberry Pi base image preparation

Follow the [official instructions](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) to install Raspbian. On a Linux host, you can also use the following quicker ones:

```
wget http://downloads.raspberrypi.org/raspbian_latest
unzip *.zip
dd bs=4M if=2015-05-05-raspbian-wheezy.img of=/dev/mmcblk0 # replace with your SD device if different
```

## OpenVPN configuration

You need to have a proper OpenVPN configuration file, say `VPN.conf`, to use this project (for a starting point, see the [official HOWTO](https://openvpn.net/index.php/open-source/documentation/howto.html#config). It is recommended to test it separately.

Copy that file and any other file it refers to in `salt/openvpn/etc_openvpn`. The configuration script will copy them to `/etc/openvpn`, so any file reference sould point there (eg. `ca`, `cert`, `key`, etc.).

Add to your configuration file the following lines:

```
# reads username and password from the first two lines of login.conf
auth-user-pass login.conf

# runs when the connection is up
up /etc/openvpn/up.sh
```

Then replace the first two lines of `salt/openvpn/etc_openvpn/login.conf` with your credentials, if any.

Finally add lines to `salt/openvpn/etc_openvpn/dnsmasq.conf` to configure any domains to be resolved by DNS servers from inside the VPN.

## SSH configuration

Copy the public SSH key you want to use to access the Raspberry Pi in `salt/sshd/authorized_keys` (password authentication is disabled in the next step). From the repo directory you can use:

```
cp ~/.ssh/id_rsa.pub salt/sshd/authorized_keys
```

## SaltStack installation

This project uses SaltStack to configure the Raspberry Pi.

To install it, insert the SD card in your Raspberry Pi and connect it to a network where you can access it, then run:

```
ssh pi@raspberrypi.local # password is raspberry

sudo su
raspi-config
# expand filesystem
# change password

echo deb http://debian.saltstack.com/debian wheezy-saltstack main >> /etc/apt/sources.list
apt-get update
apt-get -y install salt-minion
chown -R pi /srv
```

Now copy configuration files from this project onto the Raspberry Pi:

```
scp -r . pi@raspberrypi.local://srv
```

Run Salt to configure it and finally reboot:

```
ssh pi@raspberrypi.local # password is raspberry

sudo salt-call --local state.highstate
sudo reboot
```

Now change your network cables to the configuration above, done!

# Tweaking

You can change the domain name for the Raspberry Pi subnetwork in `pillar/config.sls`.

The Raspberry Pi subnet is `192.168.188.0/24` as specified in `salt/dnsmasq/dnsmasq.conf` and `salt/networking/interfaces`. You have to change those files if you want a different subnetwork.

Any other aspect can be tweaked directly in SaltStack files, which should be pretty self-explainatory.

If you make an improvement don't forget to open a pull request!
