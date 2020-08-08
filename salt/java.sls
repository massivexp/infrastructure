/dev/fd:
  mount.mounted:
    - device: fdesc
    - fstype: fdescfs
    - opts: rw
    - dump: 0
    - pass_num: 0
    - persist: True

/proc:
  mount.mounted:
    - device: proc
    - fstype: procfs
    - opts: rw
    - dump: 0
    - pass_num: 0
    - persist: True

mount -a > /root/initial-java-mount:
  cmd.run:
    - creates: /root/initial-java-mount
    - require:
      - mount:
        - /dev/fd
        - /proc
