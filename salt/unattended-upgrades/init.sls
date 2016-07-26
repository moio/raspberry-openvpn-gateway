unattended-upgrades:
  pkg:
    - installed
  require:
    - sls: postfix

  debconf.set:
    - data:
        'unattended-upgrades/enable_auto_updates':
          type: boolean
          value: "true"

  cmd.wait:
    - name: "dpkg-reconfigure unattended-upgrades"
    - watch:
      - debconf: unattended-upgrades
    - env:
        DEBIAN_FRONTEND: noninteractive
        DEBCONF_NONINTERACTIVE_SEEN: "true"

unattended-upgrades-config-source:
  file.replace:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - pattern: "//      \"o=Raspbian,n=jessie\";"
    - repl: "         \"o=Raspbian,n=jessie\";"
    - backup: False

unattended-upgrades-config-mail:
  file.replace:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - pattern: "//Unattended-Upgrade::Mail \"root\";"
    - repl: "Unattended-Upgrade::Mail \"root\";"
    - backup: False
