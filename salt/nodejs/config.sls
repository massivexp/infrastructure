/usr/local/lib/node_modules/npm/npmrc:
  file.managed:
    - source: salt:///files/npm/npmrc.jinja
    - template: jinja
    - require:
      - pkg: npm-node12-6.12.1
