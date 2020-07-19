JAVA_HOME:
  file.append:
    - name: /etc/profile
    - text: setenv JAVA_HOME /usr/local/openjdk8

/etc/fstab:
  file.append:
    - text:
      - fdesc   /dev/fd   fdescfs  rw   0  0
      - proc    /proc     procfs   rw   0  0

mount -a > /root/initial-java-mount:
  cmd.run:
    - creates: /root/initial-java-mount
    - require:
      - file: /etc/fstab
