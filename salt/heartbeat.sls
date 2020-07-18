extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /var/log/beats/heartbeat

heartbeat:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/beats/heartbeat.yml

/usr/local/etc/beats/heartbeat.yml:
  file.managed:
    - source: salt:///files/heartbeat/heartbeat.jinja.yml
    - template: jinja
