{% set package_version = "0.0.7" %}

extend:
  apache24:
    service.running:
      - require:
        - npm: install_angular_app_from_npm

git:
  pkg.installed

www/npm:
  pkg.installed

install_angular_app_from_npm:
  npm.installed:
    - name: "@massivexp/massivexp@{{ package_version }}"
    - require:
      - pkg: www/npm
