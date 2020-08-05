{% set has_lp_running = salt['mine.get']('roles:logstash', 'private_ip', tgt_type='grain').items()|length > 0 %}

/usr/local/etc/beats/metricbeat.yml:
  file.managed:
    - source: salt:///files/metricbeat/haproxy.jinja.yml
    - template: jinja
    - require:
      - pkg: beats7

metricbeat:
{% if has_lp_running %}
  service.running:
    - enable: True
    - watch:
        - file: /usr/local/etc/beats/metricbeat.yml
{% else %}
  service.dead:
    - enable: False
{% endif %}
