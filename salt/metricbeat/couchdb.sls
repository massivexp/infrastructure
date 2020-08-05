/usr/local/etc/beats/metricbeat.yml:
  file.managed:
    - source: salt:///files/metricbeat/couchdb.jinja.yml
    - template: jinja
    - require:
      - pkg: beats7

metricbeat:
  service.running:
    - enable: True
    - watch:
        - file: /usr/local/etc/beats/metricbeat.yml