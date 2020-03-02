extend:
  /usr/local/etc/haproxy.conf:
    file.managed:
      - source: salt:///files/haproxy/pm2/haproxy.app.jinja
