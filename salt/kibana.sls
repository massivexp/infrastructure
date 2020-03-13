include:
  - java
  - portsnap

portsnap extract:
  cmd.run:
    - creates: /usr/ports/textproc/kibana7
    - require:
      - cmd: portsnap_fetch

kibana:
  ports.installed:
    - name: textproc/kibana7
    - require:
      - cmd: portsnap extract
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/etc/kibana/kibana.yml

/usr/local/etc/kibana/kibana.yml:
  file.managed:
    - source: salt:///files/kibana/kibana.jinja.yml
    - template: jinja
