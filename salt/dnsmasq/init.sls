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
      - file: /etc/hosts.dnsmasq

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

dnsmasq_hosts_file:
  file.managed:
    - name: /etc/hosts.dnsmasq
    - contents: 192.168.188.1 {{ salt['pillar.get']('hostname','raspberrypi') }}.{{ salt['pillar.get']('domain','moio') }} {{ salt['pillar.get']('hostname','raspberrypi') }}
    - user: root
    - group: root
    - mode: 644
