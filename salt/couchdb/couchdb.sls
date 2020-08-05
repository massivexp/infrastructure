{% set schema = {
  '_users': false,
  '_global_changes': false,
  '_replicator': false,
  'experiences': '{\\"admins\\": {\\"roles\\": [\\"admin\\"]}, \\"members\\": {\\"roles\\": [\\"mkeen_guest\\"]}}',
  'organizations': false,
  'experiences_ingress_running': false,
  'experiences_aggregate_running': false,
} %}

{% set seed = {
  'experiences': '{\\"_id\\": \\"library\\", \\"names\\": [\\"conversation\\"]}',
  'experiences_ingress_running': '{\\"_id\\": \\"index\\", \\"running\\": []}',
  'experiences_aggregate_running': '{\\"_id\\": \\"index\\", \\"running\\": []}'
} %}

include:
  - metricbeat.couchdb

extend:
  filebeat:
    service.running:
      - require:
        - file: /var/log/couchdb3
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
          specific_log_files:
            - /var/log/couchdb3/couch.log
  /usr/local/etc/salt/minion.d/mine.conf:
    file.managed:
      - source: salt:///files/salt/mine.couchdb.jinja.conf

set_dbowner:
  cmd.run:
    - name: "chown couchdb /mnt/storage && echo \"\" > /root/setup-dbowner"
    - creates: /root/setup-dbowner
    - require:
      - cmd: storage_bootstrap
      - pkg: couchdb3

couchdb3:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/couchdb3/local.ini
    - require:
      - cmd: storage_bootstrap
      - cmd: set_dbowner
      - file: /var/log/couchdb3
      - file: /var/run/couchdb

/usr/local/etc/couchdb3/local.ini:
  file.managed:
    - source: salt:///files/couchdb/local.jinja.ini
    - template: jinja
    - user: couchdb
    - group: couchdb
    - require:
      - pkg: couchdb3

/mnt/storage:
  file.directory:
    - user: couchdb
    - group: couchdb
    - require:
      - cmd: storage_bootstrap
      - pkg: couchdb3

/var/log/couchdb3:
  file.directory:
    - user: couchdb
    - group: couchdb
    - require:
      - pkg: couchdb3

/var/run/couchdb:
  file.directory:
    - user: couchdb
    - group: couchdb
    - require:
      - pkg: couchdb3

{% if grains['id'] == 'couchdb-a' %}
{% for database in schema %}
"curl -X PUT -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/{{ [database][0] }}' -d '' > '/root/created-{{ [database][0] }}-database'":
  cmd.run:
    - creates: /root/created-{{ [database][0] }}-database
    - hide_output: True
    - output_loglevel: quiet
    - require:
      - service: couchdb3
{% endfor %}

"curl -X POST -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/experiences' -d '{{ seed['experiences'] }}' > '/root/seeded-experiences'":
  cmd.run:
    - creates: /root/seeded-experiences
    - hide_output: True
    - output_loglevel: quiet

"curl -X POST -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/experiences_ingress_running' -d '{{ seed['experiences_ingress_running'] }}' > '/root/seeded-experiences_ingress_running'":
  cmd.run:
    - creates: /root/seeded-experiences_ingress_running
    - hide_output: True
    - output_loglevel: quiet

"curl -X POST -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/experiences_aggregate_running' -d '{{ seed['experiences_aggregate_running'] }}' > '/root/seeded-experiences_aggregate_running'":
  cmd.run:
    - creates: /root/seeded-experiences_aggregate_running
    - hide_output: True
    - output_loglevel: quiet
{% endif %}
# terragon 2019-2020
