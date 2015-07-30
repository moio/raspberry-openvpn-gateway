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
      - file: authorized_keys

sshd:
  pkg.installed:
    - name: openssh-server
  service.running:
    - name: ssh
    - enable: True
    - watch:
      - file: sshd_config
    - require:
      - pkg: sshd
      - file: sshd_config
