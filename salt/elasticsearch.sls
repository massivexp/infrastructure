extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /var/log/elasticsearch/elasticsearch.log
          - /var/log/elasticsearch/elasticsearch_access.log
          - /var/log/elasticsearch/elasticsearch_audit.log
          - /var/log/elasticsearch/elasticsearch_index_search_slowlog.log
          - /var/log/elasticsearch/elasticsearch_index_indexing_slowlog.log

include:
  - java

make_admin:
  cmd.run:
    - name: /usr/local/lib/elasticsearch/bin/elasticsearch-users useradd "{{ grains['elastic_user'] }}" -p "{{ grains['elastic_pass'] }}" -r superuser > /dev/null && touch /root/setup-elastic-user
    - creates: /root/setup-elastic-user
    - env:
      - JAVA_HOME: /usr/local/openjdk8
    - require:
      - cmd: touch /usr/local/lib/elasticsearch/config/users

elasticsearch:
  pkg.installed:
    - name: elasticsearch7
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/elasticsearch/elasticsearch.yml
    - require:
      - cmd: make_admin

/usr/local/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt:///files/elasticsearch/elasticsearch.jinja.yml
    - template: jinja
    - require:
      - pkg: elasticsearch
  
touch /usr/local/lib/elasticsearch/config/users:
  cmd.run:
    - creates: /usr/local/lib/elasticsearch/config/users
    - require:
      - pkg: elasticsearch
