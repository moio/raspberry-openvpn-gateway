locale-gen-config:
  file.replace:
    - name: /etc/locale.gen
    - pattern: "# {{ salt['pillar.get']('locale','en_US') }}.UTF-8 UTF-8"
    - repl: "{{ salt['pillar.get']('locale','en_US') }}.UTF-8 UTF-8"
    - backup: False
    - unless: grep "^{{ salt['pillar.get']('locale','en_US') }}.UTF-8 UTF-8" /etc/locale.gen

locale-gen-config-additional:
  file.replace:
    - name: /etc/locale.gen
    - pattern: "# {{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8 UTF-8"
    - repl: "{{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8 UTF-8"
    - backup: False
    - unless: grep "^{{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8 UTF-8" /etc/locale.gen

locale-config:
  file.managed:
    - name: /etc/default/locale
    - contents: "LANG={{ salt['pillar.get']('locale','en_US') }}.UTF-8\nLC_TIME=\"{{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8\"\nLC_PAPER=\"{{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8\"\nLC_MEASUREMENT=\"{{ salt['pillar.get']('additional_locale','en_GB') }}.UTF-8\"\n"

locale-reconfigure:
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive locales
    - require:
      - file: locale-gen-config
      - file: locale-gen-config-additional
      - file: locale-config

locale-update:
  cmd.run:
    - name: update-locale LANG={{ salt['pillar.get']('locale','en_US') }}.UTF-8
  require:
    - cmd: locale-reconfigure
