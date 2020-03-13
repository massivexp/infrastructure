salt_minion:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/salt/minion.d/mine.conf
      - file: /usr/local/etc/salt/minion.d/98-minion-config.conf

/usr/local/etc/salt/minion.d/mine.conf:
  file.managed:
    - source: salt:///files/salt/mine.jinja.conf
    - template: jinja

/usr/local/etc/salt/minion.d/98-minion-config.conf:
  file.managed:
    - source: salt:///files/salt/98-minion-config.jinja.conf
    - template: jinja
