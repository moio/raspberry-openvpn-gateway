dnsmasq:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: dnsmasq
    - watch:
      - file: /etc/dnsmasq.conf

/etc/dnsmasq.conf:
  file.managed:
    - source: salt://dnsmasq/dnsmasq.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: dnsmasq
