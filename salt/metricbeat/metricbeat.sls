/proc:
  mount.mounted:
    - device: proc
    - fstype: procfs
    - persist: True

/compat/linux/proc:
  mount.mounted:
    - fstype: linprocfs
    - device: /dev/null
    - persist: True
    - mkmnt: True

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
          - mount: /compat/linux/proc
          - mount: /proc
      - watch:
          - file: /usr/local/etc/beats/metricbeat.yml