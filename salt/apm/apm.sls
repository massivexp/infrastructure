go:
  pkg.installed: []

git:
  pkg.installed: []

https://github.com/massivexp/apm-server.git:
  git.cloned:
    - target: /usr/local/go/src/github.com/elastic/apm-server
    - require:
      - pkg: git
      - pkg: go

compile_apm:
  cmd.run:
    - cwd: /usr/local/go/src/github.com/elastic/apm-server
    - name: |
        make
        make update
    - require:
      - git: https://github.com/massivexp/apm-server.git