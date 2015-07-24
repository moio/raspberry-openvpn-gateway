ufw:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: ufw
    - watch:
      - file: /etc/ufw
      - file: /lib/ufw
      - file: /etc/default/ufw

/etc/ufw:
  file.recurse:
    - source: salt://ufw/etc_ufw

/lib/ufw:
  file.recurse:
    - source: salt://ufw/lib_ufw

/etc/default/ufw:
  file.managed:
    - source: salt://ufw/etc_default_ufw
