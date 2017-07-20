unattended-upgrades:
  pkg:
    - installed

  debconf.set:
    - data:
        'unattended-upgrades/enable_auto_updates':
          type: boolean
          value: "true"
    - require:
      - pkg: unattended-upgrades

  cmd.wait:
    - name: "dpkg-reconfigure unattended-upgrades"
    - env:
        DEBIAN_FRONTEND: noninteractive
        DEBCONF_NONINTERACTIVE_SEEN: "true"
    - require:
      - pkg: unattended-upgrades
    - watch:
      - debconf: unattended-upgrades

unattended-upgrades-config-source:
  file.replace:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - pattern: "//      \"o=Raspbian,n=jessie\";"
    - repl: "         \"o=Raspbian,n=jessie\";"
    - backup: False
