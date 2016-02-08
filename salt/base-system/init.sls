trust Salt repo key:
  cmd.run:
    - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B09E40B0F2AE6AB9
    - unless: apt-key list | grep '4096R/F2AE6AB9'

upgrade all packages:
  pkg.uptodate:
    - refresh: True
    - require:
      - cmd: trust Salt repo key
