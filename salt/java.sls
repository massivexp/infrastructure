/dev/fd:
  mount.mounted:
    - device: fdesc
    - fstype: fdescfs
    - opts: rw
    - dump: 0
    - pass_num: 0

/proc:
  mount.mounted:
    - device: proc
    - fstype: procfs
    - opts: rw
    - dump: 0
    - pass_num: 0
