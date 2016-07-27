set masterless minion:
  file.append:
    - name: /etc/salt/minion
    - text: "file_client: local"

salt-minion:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/salt/minion
