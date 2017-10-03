generate rsa key:
  cmd.run:
    - name: |
        cd /etc/ssh && rm ssh_host_*key*
        ssh-keygen -t ed25519 -N "" -f ssh_host_ed25519_key
        ssh-keygen -t rsa -N "" -b 4096 -f ssh_host_rsa_key
    - unless: openssl rsa -text -noout -in /etc/ssh/ssh_host_rsa_key | grep "4096 bit" && test -f /etc/ssh/ssh_host_ed25519_key
    - require:
      - pkg: sshd

purge moduli:
  cmd.run:
    - name: |
        awk '$5 > 2000' /etc/ssh/moduli > /tmp/moduli
        test -s /tmp/moduli && mv /tmp/moduli /etc/ssh/moduli
    - onlyif: awk '$5 <= 2000' /etc/ssh/moduli | grep '.'

authorized_keys:
  file.managed:
    - source: salt://sshd/authorized_keys
    - name: /home/pi/.ssh/authorized_keys
    - makedirs: True
    - user: pi
    - group: pi
    - mode: 600

sshd_config:
  file.managed:
    - source: salt://sshd/sshd_config
    - name: /etc/ssh/sshd_config
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: sshd
      - cmd: generate rsa key
      - file: authorized_keys

sshd:
  pkg.installed:
    - pkgs:
      - openssh-server
      - openssl
  service.running:
    - name: ssh
    - enable: True
    - watch:
      - file: sshd_config
    - require:
      - pkg: sshd
      - file: sshd_config
