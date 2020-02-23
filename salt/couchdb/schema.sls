schema:
  databases:
    - _users
    - _global_changes
    - _replicator
  security:
    ingress_mkeen_comments_0:
      admins:
        names:
          - mkeen_member
      members:
        roles:
          - mkeen_guest
    state_mkeen_comments_0:
      admins:
        names:
          - {{ grains['couch_user'] }}
      members:
        roles:
          - mkeen_guest
