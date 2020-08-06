#sudo mount -t procfs proc /proc
#sudo mkdir -p /compat/linux/proc
#sudo mount -t linprocfs /dev/null /compat/linux/proc

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
          - mount: /compat/linux/proc
          - mount: /proc
      - watch:
          - file: /usr/local/etc/beats/metricbeat.yml