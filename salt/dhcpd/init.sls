dhcpd:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: dhcp-server
    - watch:
      - file: /etc/dhcpd.conf
      - file: /etc/sysconfig/dhcpd

/etc/dhcpd.conf:
  file.managed:
    - source: salt://dhcpd/dhcpd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: dhcp-server

/etc/sysconfig/dhcpd:
  file.managed:
    - source: salt://dhcpd/dhcpd
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: dhcp-server
