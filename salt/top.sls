base:
  '*':
    - minion
    - eastern_standard_time
    - security
    - fastboot

  'saltm':
    - master

  'roles:storage':
    - match: grain
    - storage

  'roles:haproxy':
    - match: grain
    - letsencrypt
    - haproxy.haproxy

  'roles:apache':
    - match: grain
    - letsencrypt
    - apache.apache

  'roles:logstash':
    - match: grain
    - logstash

  'roles:heartbeat':
    - match: grain
    - heartbeat

  'roles:elasticsearch':
    - match: grain
    - elasticsearch

  'G@roles:kibana and not G@roles:haproxy':
    - match: compound
    - kibana

  'G@roles:haproxy and G@roles:kibana':
    - match: compound
    - haproxy.kibana

  'G@roles:couchdb and not G@roles:haproxy':
    - match: compound
    - couchdb

  'G@roles:couchdb and G@roles:haproxy':
    - match: compound
    - haproxy.couchdb

  'nodejs_pipeline':
    - nodejs_pipeline

  'G@roles:pm2 and G@roles:haproxy':
    - match: compound
    - haproxy.pm2

  'roles:angular':
    - match: grain
    - apache.angular
    - angular
