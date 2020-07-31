py27-certbot:
  pkg.installed

extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
          other_log_files:
            - /var/log/letsencrypt/letsencrypt.log
  haproxy:
    service.running:
      - watch:
        - file: /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/{{grains['fqdn']}}.pem

certbot-2.7 certonly --non-interactive --standalone -d {{grains['fqdn']}} --agree-tos -m freebsd@{{grains['fqdn']}}:
  cmd.run:
    - creates: /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/privkey.pem
    - require:
      - pkg: py27-certbot

cat /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/privkey.pem /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/cert.pem | tee /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/{{grains['fqdn']}}.pem:
  cmd.run:
    - creates: /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/{{grains['fqdn']}}.pem
    - require:
      - pkg: py27-certbot

certbot-2.7 renew --http-01-port=8888 --standalone -q && cat /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/privkey.pem /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/cert.pem | tee /usr/local/etc/letsencrypt/live/{{grains['fqdn']}}/{{grains['fqdn']}}.pem:
  cron.present:
    - user: root
    - special: '@daily'
