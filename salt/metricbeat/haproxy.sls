extend:
  /usr/local/etc/beats/metricbeat.yml:
    file.managed:
      - source: salt:///files/metricbeat/haproxy.jinja.yml
