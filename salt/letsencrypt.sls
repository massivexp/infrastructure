{% set cert_domains = [grains['fqdn'], 'massivexp.com'] if 'root' in grains['roles'] else [grains['fqdn']] %}

py27-certbot:
  pkg.installed

extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
          other_log_files:
            - /var/log/letsencrypt/letsencrypt.log

{% for cert_domain in cert_domains %}
certbot-2.7 certonly --non-interactive --standalone -d {{cert_domain}} --agree-tos -m freebsd@{{cert_domain}}:
  cmd.run:
    - creates: /usr/local/etc/letsencrypt/live/{{cert_domain}}/privkey.pem
    - require:
      - pkg: py27-certbot

cat /usr/local/etc/letsencrypt/live/{{cert_domain}}/privkey.pem /usr/local/etc/letsencrypt/live/{{cert_domain}}/cert.pem /usr/local/etc/letsencrypt/live/{{cert_domain}}/fullchain.pem | tee /usr/local/etc/letsencrypt/live/{{cert_domain}}/{{cert_domain}}.pem:
  cmd.run:
    - creates: /usr/local/etc/letsencrypt/live/{{cert_domain}}/{{cert_domain}}.pem
    - require:
      - pkg: py27-certbot
    
certbot-2.7 renew --non-interactive --post-hook "cat /usr/local/etc/letsencrypt/live/{{cert_domain}}/fullchain.pem /usr/local/etc/letsencrypt/live/{{cert_domain}}/privkey.pem | tee /usr/local/etc/letsencrypt/live/{{cert_domain}}/{{cert_domain}}.pem && service haproxy reload":
  cron.absent:
    - user: root
    - special: '@daily'
    
certbot-2.7 renew --non-interactive --post-hook "cat /usr/local/etc/letsencrypt/live/{{cert_domain}}/privkey.pem /usr/local/etc/letsencrypt/live/{{cert_domain}}/cert.pem /usr/local/etc/letsencrypt/live/{{cert_domain}}/fullchain.pem | tee /usr/local/etc/letsencrypt/live/{{cert_domain}}/{{cert_domain}}.pem && service haproxy reload":
    cron.present:
      - user: root
      - special: '@daily'
    
{% endfor %}
