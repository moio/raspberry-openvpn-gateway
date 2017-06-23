dnsmasq:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: dnsmasq
    - watch:
      - file: /etc/dnsmasq.d/custom.conf

dnsmasq_custom_config_file:
  file.managed:
    - name: /etc/dnsmasq.d/custom.conf
    - source: salt://dnsmasq/custom.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: dnsmasq

