networking:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/network/interfaces

/etc/network/interfaces:
  file.managed:
    - source: salt://networking/interfaces
    - template: jinja
    - user: root
    - group: root
    - mode: 644
