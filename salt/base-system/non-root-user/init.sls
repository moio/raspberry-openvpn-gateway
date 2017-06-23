user-creation:
  user.present:
    - name: {{ salt['pillar.get']('user_name', 'user') }}
    - password: $1$LioLpkU4$3HYx.bRJmq79nCZcvyoDw1 # changeme
    - enforce_password: False
    - gid: users
    - fullname: {{ salt['pillar.get']('user_real_name', 'User') }}
    - shell: /bin/bash
    - groups:
      - sudo
      - adm
      - dialout
      - cdrom
      - audio
      - video
      - plugdev
      - games
      - input
      - netdev
      - spi
      - i2c
      - gpio

user-creation-force-password-change:
  cmd.run:
    - name: "chage -d 0 {{ salt['pillar.get']('user_name') }}"
    - onchanges:
      - user: user-creation

/srv:
  file.directory:
    - user: {{ salt['pillar.get']('user_name', 'user') }}
    - group: users
    - recurse:
       - user
       - group
    - onchanges:
      - user: user-creation

pi-user-deletion:
  user.absent:
    - name: pi
    - purge: True
    - force: True
  require:
    - sls: sshd
