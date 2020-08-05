/usr/local/lib/node_modules/npm/npmrc:
  file.managed:
    - source: salt:///files/npm/npmrc.jinja
    - template: jinja
    - require:
      - pkg: npm
    - defaults:
      github_token: {{grains['github_token']}}
