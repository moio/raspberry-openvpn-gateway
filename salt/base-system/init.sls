hosts-file:
  file.append:
    - name: /etc/hosts
    - text: "192.168.188.1 {{ salt['pillar.get']('hostname','raspberrypi') }}.{{ salt['pillar.get']('domain','moio') }} {{ salt['pillar.get']('hostname','raspberrypi') }}"

set-temporary-hostname:
  cmd.run:
    - name: hostnamectl set-hostname {{ salt['pillar.get']('hostname','raspberrypi') }}

set-permanent-hostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ salt['pillar.get']('hostname','raspberrypi') }}

trust Salt repo key:
  cmd.run:
    - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B09E40B0F2AE6AB9
    - unless: apt-key list | grep '4096R/F2AE6AB9'

upgrade all packages:
  pkg.uptodate:
    - refresh: True
    - require:
      - cmd: trust Salt repo key
