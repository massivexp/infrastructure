extend:
  /etc/fstab:
    file.append:
      - text:
        - /dev/null /compat/linux/proc linprocfs rw   0  0

/bin/lsof:
  file.symlink:
    - target: /usr/local/sbin/lsof

/usr/local/etc/beats/metricbeat.yml:
  file.managed:
    - source: salt:///files/metricbeat/metricbeat.jinja.yml
    - template: jinja
    - require:
      - pkg: beats7

metricbeat:
  service.running:
      - enable: True
      - require:
          - file: /usr/local/etc/beats/metricbeat.yml
      - watch:
          - file: /usr/local/etc/beats/metricbeat.yml
