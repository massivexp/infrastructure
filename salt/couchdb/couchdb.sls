{% set schema = {
  '_users': false,
  '_global_changes': false,
  '_replicator': false,
  'ingress_mkeen_comments_0': '{\\"admins\\": {\\"roles\\": [\\"mkeen_member\\"]}, \\"members\\": {\\"roles\\": [\\"mkeen_guest\\"]}}',
  'aggregate_mkeen_comments_0': '{\\"admins\\": {\\"roles\\": [\\"admin\\"]}, \\"members\\": {\\"roles\\": [\\"mkeen_guest\\"]}}'
} %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /var/log/couchdb2/couch.log
  /usr/local/etc/salt/minion.d/mine.conf:
    file.managed:
      - source: salt:///files/salt/mine.couchdb.jinja.conf

couchdb2:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - cmd: storage_bootstrap
    - watch:
      - file: /usr/local/etc/couchdb2/local.d/custom.ini
      - file: /usr/local/etc/couchdb2/vm.args
      - file: /usr/local/etc/rc.d/couchdb2

/usr/local/etc/couchdb2/local.d:
  file.directory:
    - user: couchdb
    - group: couchdb
    - require:
      - pkg: couchdb2

/usr/local/etc/couchdb2/local.d/custom.ini:
  file.managed:
    - source: salt:///files/couchdb/local.jinja.ini
    - template: jinja
    - user: couchdb
    - group: couchdb
    - require:
      - pkg: couchdb2
      - file: /usr/local/etc/couchdb2/local.d

/usr/local/etc/couchdb2/vm.args:
  file.managed:
    - source: salt:///files/couchdb/vm.jinja.args
    - template: jinja
    - require:
      - pkg: couchdb2

/usr/local/etc/rc.d/couchdb2:
  file.managed:
    - source: salt:///files/couchdb/rc.conf
    - require:
      - pkg: couchdb2
      - file: /usr/local/etc/couchdb2/local.d/custom.ini

/mnt/storage:
  file.directory:
    - user: couchdb
    - group: couchdb
    - require:
      - cmd: storage_bootstrap

{% if grains['id'] == 'couchdb-a' %}
{% for database in schema %}
"curl -X PUT -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/{{ [database][0] }}' -d '' > '/root/created-{{ [database][0] }}-database'":
  cmd.run:
    - creates: /root/created-{{ [database][0] }}-database
    - hide_output: True
    - output_loglevel: quiet
    - require:
      - service: couchdb2
{% if schema[[database][0]] %}
"curl -X PUT -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/{{ [database][0] }}/_security' -d '{{ schema[[database][0]] }}' > '/root/created-{{ [database][0] }}-security'":
  cmd.run:
    - creates: /root/created-{{ [database][0] }}-security
    - hide_output: True
    - output_loglevel: quiet
    - require:
      - cmd: "curl -X PUT -H \"Content-Type: application/json\" 'http://{{ grains['couch_user'] }}:{{ grains['couch_pass'] }}@{{ salt['network.interface_ip']('vtnet1') }}:5984/{{ [database][0] }}' -d '' > '/root/created-{{ [database][0] }}-database'"
{% endif %}
{% endfor %}
{% endif %}

# terragon 2019-2020
