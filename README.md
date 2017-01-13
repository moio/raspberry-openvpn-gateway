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
 |              |      +---->|                | integrated |                |   USB      XXX                               X        |                 |
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
 - [TRENDNET TU3-ETG USB3 Gigabit Ethernet adapter](https://www.trendnet.com/products/proddetail.asp?prod=315_TU3-ETG) (eth1 in the diagram above);

## Raspberry Pi base image preparation

Follow the [official instructions](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) to install Raspbian. On a Linux host, you can also use the following quicker ones:

```
wget https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2015-11-24/2015-11-21-raspbian-jessie-lite.zip
unzip *.zip
sudo dd bs=4M if=`ls *.img` of=/dev/mmcblk0 # replace with your SD device (check journalctl)
```

### Note

As of the November 2016 release, Raspbian has the [SSH server disabled by default](https://www.raspberrypi.org/documentation/remote-access/ssh/).
In order to enable ssh :

```
# mkdir -p /run/media/mbologna/boot
# mount -t vfat /dev/mmcblk0p1 /run/media/mbologna/boot # check partition number on your setup
# touch /run/media/mbologna/boot/ssh
# sync && umount /run/media/mbologna/boot/
```

## Boot your Raspberry PI

Connect your Raspberry PI (just Ethernet and power, you do not need a screen).

## Providing configuration
### Prepare OpenVPN configuration

You need to have a proper OpenVPN configuration file, say `VPN.conf`, to use this project (for a starting point, see the [official HOWTO](https://openvpn.net/index.php/open-source/documentation/howto.html#config). It is recommended to test it separately.

Copy that file and any other file it refers to in `salt/openvpn/etc_openvpn`. The configuration script will copy them to `/etc/openvpn`, so any file reference should point there (eg. `ca`, `cert`, `key`, etc.).

Ensure your configuration file contains the following lines:

```
# reads username and password from the first two lines of login.settings
auth-user-pass login.settings

# runs when the connection is up
up /etc/openvpn/up.sh
```

Then replace the first two lines of `salt/openvpn/etc_openvpn/login.settings` with your credentials, if any.

Finally add lines to `salt/openvpn/etc_openvpn/dnsmasq.settings` to configure any domains to be resolved by DNS servers from inside the VPN.

### SSH configuration

Copy the public SSH key you want to use to access the Raspberry Pi in `salt/sshd/authorized_keys` (password authentication is disabled in the next step). From the repo directory you can use:

```
cp ~/.ssh/id_rsa.pub salt/sshd/authorized_keys
```

### Salt installation

This project uses Salt to configure the Raspberry Pi.

To install it, insert the SD card in your Raspberry Pi and connect it to a network where you can access it. Don't connect the USB Ethernet interface yet, and run the following commands:

```
ssh pi@raspberrypi.local # password is raspberry

sudo raspi-config
# expand filesystem
# change password
# i18n options -> change locale (personal preference: en-US.UTF-8)
# i18n options -> change timezone
# finish and reboot

echo deb http://debian.saltstack.com/debian jessie-saltstack main | sudo tee --append /etc/apt/sources.list
gpg --keyserver pgpkeys.mit.edu --recv-key  B09E40B0F2AE6AB9
gpg -a --export B09E40B0F2AE6AB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install salt-minion
sudo chown -R pi /srv
```

Now copy configuration files from this project onto the Raspberry Pi:

```
rsync -e ssh -avz --progress --delete --exclude=.git . pi@raspberrypi.local://srv
```

Run Salt to configure it and finally reboot:

```
ssh pi@raspberrypi.local

sudo salt-call --local state.highstate
sudo shutdown -h now
```

Now change your network cables to the configuration above, done!

## Post-install access

SSH is configured to accept connections on port 22. Note that security settings are [tuned as per recent recommended standards](https://stribika.github.io/2015/01/04/secure-secure-shell.html), including the fact that the RSA key is regenerated with key length 4096 bits, so you will get warnings on first connection attempt.

# Tweaking

You can change the domain name for the Raspberry Pi subnetwork in `pillar/config.sls`.

The Raspberry Pi subnet is `192.168.188.0/24` as specified in `salt/dnsmasq/dnsmasq.settings` and `salt/networking/interfaces`. You have to change those files if you want a different subnetwork.

Any other aspect can be tweaked directly in SaltStack files, which should be pretty self-explainatory.

If you make an improvement don't forget to open a pull request!
