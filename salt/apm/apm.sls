go:
  pkg.installed: []

git:
  pkg.installed: []

gmake:
  pkg.installed: []

py37-pillow:
  pkg.installed: []

https://github.com/massivexp/apm-server.git:
  git.cloned:
    - target: /usr/local/go/src/github.com/elastic/apm-server
    - require:
      - pkg: git
      - pkg: go

/usr/local/bin/python3:
  file.symlink:
    - target: /usr/local/bin/python3.7

compile_apm:
  cmd.run:
    - cwd: /usr/local/go/src/github.com/elastic/apm-server
    - name: gmake && gmake update
    - require:
      - git: https://github.com/massivexp/apm-server.git
      - pkg: gmake
      - pkg: py37-pillow

/usr/local/go/src/github.com/elastic/apm-server/apm-server.yml:
  file.managed:
    - source: salt:///files/apm/apm-server.jinja.yml
    - template: jinja
    - require:
      - cmd: compile_apm

./apm-server -c apm-server.yml -e -d \*:
  cmd.run:
    - cwd: /usr/local/go/src/github.com/elastic/apm-server
    - require:
        - cmd: compile_apm