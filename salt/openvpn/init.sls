openvpn:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: openvpn
    - watch:
      - file: /etc/openvpn

/etc/openvpn:
  file.recurse:
    - source: salt://openvpn/etc_openvpn
    - template: jinja
    - user: root
    - group: root
    - exclude_pat: E@(dnsmasq.settings.default)|(login.settings.default)
    - file_mode: 600

/etc/openvpn/up.sh:
  file.managed:
    - source: salt://openvpn/up.sh
    - user: root
    - group: root
    - mode: 700
