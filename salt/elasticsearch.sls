extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /var/log/elasticsearch/massivexp-logging.log
          - /var/log/elasticsearch/massivexp-logging_index_search_slowlog.log

include:
  - java

elasticsearch:
  pkg.installed:
    - name: elasticsearch7
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/elasticsearch/elasticsearch.yml
      - file: /usr/local/etc/elasticsearch/jvm.options
    - require:
      - cmd: finalize_make_admin

/usr/local/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt:///files/elasticsearch/elasticsearch.jinja.yml
    - template: jinja
    - require:
      - pkg: elasticsearch

/usr/local/etc/elasticsearch/jvm.options:
  file.managed:
    - source: salt:///files/elasticsearch/jvm.jinja.options
    - template: jinja
    - require:
      - pkg: elasticsearch
  
touch /usr/local/lib/elasticsearch/config/users:
  cmd.run:
    - creates: /usr/local/lib/elasticsearch/config/users
    - require:
      - pkg: elasticsearch

make_admin:
  cmd.run:
    - name: /usr/local/lib/elasticsearch/bin/elasticsearch-users useradd '{{ grains['elastic_user'] }}' -p '{{ grains['elastic_pass'] }}' -r superuser || true > /root/.created-elastic-admin
    - creates: /root/.created-elastic-admin
    - env:
      - JAVA_HOME: /usr/local/openjdk8
    - require:
      - cmd: touch /usr/local/lib/elasticsearch/config/users
      - service: elasticsearch

finalize_make_admin:
  cmd.run:
    - name: touch /root/setup-elastic-user
    - creates: /root/setup-elastic-user
    - require:
      - cmd: make_admin

{% if 'storage' in grains['roles'] %}
/mnt/storage:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - require:
      - cmd: storage_bootstrap
{% endif %}
