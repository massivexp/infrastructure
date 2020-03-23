{% set package_version = "0.0.7" %}

extend:
  apache24:
    service.running:
      - require:
        - npm: install_angular_app_from_npm

git:
  pkg.installed

npm-node12-6.12.1:
  pkg.installed

install_angular_app_from_npm:
  npm.installed:
    - name: "@massivexp/massivexp@{{ package_version }}"
    - require:
      - pkg: npm-node12-6.12.1
