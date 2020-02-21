interface: ${private_ip}
fileserver_backend:
  - git

gitfs_remotes:
  - git@github.com:massivexp/infrastructure.git:
    - mountpoint: salt:///

gitfs_root: salt
gitfs_privkey: /root/.ssh/id_rsa
gitfs_pubkey: /root/.ssh/id_rsa.pub

transport: zeromq
file_recv: True
#pillar_roots:
#  base:
#    - /srv/pillar
