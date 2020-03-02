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

  'roles:logstash':
    - match: grain
    - logstash

  'roles:heartbeat':
    - match: grain
    - heartbeat

  'roles:elasticsearch':
    - match: grain
    - elasticsearch

  'G@roles:pm2 and not G@roles:haproxy':
    - match: compound
    - nodejs.config
    - nodejs.nodejs

  'kibana-*':
    - kibana

  'haproxy-kibana-*':
    - haproxy.kibana

  'couchdb-*':
    - couchdb.couchdb

  'haproxy-couchdb-*':
    - haproxy.couchdb

  'nodejs-pipeline-*':
    - nodejs.pipeline

  'nodejs-api-*':
    - nodejs.api

  'nodejs-www-*':
    - nodejs.app

  'haproxy-nodejs-www-*':
    - haproxy.app
