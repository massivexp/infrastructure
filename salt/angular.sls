extend:
  apache24:
    service.running:
      - require:
        - npm: "@massivexp/dashboard@0.0.1"

git:
  pkg.installed

www/npm:
  pkg.installed

"@massivexp/dashboard@0.0.1":
  npm.installed:
    - require:
      - pkg: www/npm
