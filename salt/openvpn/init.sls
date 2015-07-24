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
    - file_mode: 644

/etc/openvpn/up.sh:
  file.managed:
    - source: salt://openvpn/up.sh
    - user: root
    - group: root
    - mode: 755
