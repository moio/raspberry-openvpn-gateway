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
      - file: /etc/systemd/system/openvpn@.service.d/restart.conf

/etc/openvpn:
  file.recurse:
    - source: salt://openvpn/etc_openvpn
    - template: jinja
    - user: root
    - group: root
    - file_mode: 600

/etc/openvpn/up.sh:
  file.managed:
    - source: salt://openvpn/up.sh
    - user: root
    - group: root
    - mode: 700

/etc/systemd/system/openvpn@.service.d/restart.conf:
  file.managed:
    - source: salt://openvpn/openvpn@.service.d/restart.conf
    - user: root
    - group: root
    - mode: 644
    - dir_mode: 755
    - makedirs: True
