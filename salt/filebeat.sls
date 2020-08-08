beats7:
  pkg.installed

/usr/local/etc/beats/filebeat.yml:
  file.managed:
    - source: salt:///files/filebeat/filebeat.jinja.yml
    - template: jinja
    - require:
      - pkg: beats7
    - defaults:
      log_files:
        - /var/log/auth.log
        - /var/log/salt/minion
        - /var/log/userlog
      general_log_files: []
      specific_log_files: []
      other_log_files: []

filebeat:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/beats/filebeat.yml
