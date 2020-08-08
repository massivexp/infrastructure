/compat/linux/proc:
  mount.mounted:
    - device: linproc
    - fstype: linprocfs
    - opts: rw
    - dump: 0
    - pass_num: 0

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
