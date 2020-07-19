extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /var/log/elasticsearch/kibana.log

include:
  - java

kibana:
  pkg.installed:
    - name: kibana7
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/kibana/kibana.yml

/usr/local/etc/kibana/kibana.yml:
  file.managed:
    - source: salt:///files/kibana/kibana.jinja.yml
    - template: jinja
    - require:
      - pkg: kibana
  