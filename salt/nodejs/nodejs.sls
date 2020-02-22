libnghttp2:
  pkg.installed:
    - refresh_db: True

pkg install -y libnghttp2:
  cmd.run:
    - unless: npm version

www/npm:
  pkg.installed:
    - require:
      - cmd: pkg install -y libnghttp2

/usr/local/lib/node_modules/npm/npmrc:
  file.managed:
    - source: salt:///files/npm/npmrc.jinja
    - template: jinja
    - require:
      - pkg: www/npm

install_package_from_npm:
  npm.installed:
    - name: "@massivexp/pipeline@0.0.1"

pm2:
  npm.installed:
    - require:
      - pkg: www/npm

pm2 startup --hp /:
  cmd.run:
    - runas: root
    - creates: /usr/local/etc/rc.d/pm2_root
    - env:
      - PM2_API_IPADDR: {{ salt['network.interface_ip']('vtnet1') }}
    - require:
      - cmd: pm2 start --hp / /usr/local/etc/process.yml

pm2 start --hp / /usr/local/etc/process.yml:
  cmd.run:
    - env:
      - PM2_API_IPADDR: {{ salt['network.interface_ip']('vtnet1') }}
    - unless: pm2 describe --hp / pipeline
    - require:
      - npm: pm2
      - npm: install_package_from_npm
      - file: /usr/local/etc/process.yml

pm2_root:
  service.running:
    - enable: True
    - require:
      - cmd: pm2 startup --hp /

/usr/local/etc/process.yml:
  file.managed:
    - source: salt:///files/nodejs/pm2.process.jinja.yml
    - template: jinja
    - defaults:
      package_name: "pipeline"
      http_cors_origin: ""