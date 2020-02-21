interface: ${private_ip}
fileserver_backend:
  - git

gitfs_remotes:
  - https://github.com/massivexp/infrastructure.git:
    - mountpoint: salt:///

gitfs_root: salt
transport: zeromq
file_recv: True
#pillar_roots:
#  base:
#    - /srv/pillar
