timezone-config:
  file.managed:
    - name: /etc/timezone
    - contents: {{ salt['pillar.get']('timezone','Europe/Rome') }}

timezone-reconfigure:
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive tzdata
    - require:
      - file: timezone-config
    - onchanges:
      - file: /etc/timezone
