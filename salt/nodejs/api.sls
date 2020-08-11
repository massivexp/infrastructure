{% set package_version = "0.0.24" %}

extend:
  /usr/local/etc/beats/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/api-error.log
          - /.pm2/logs/api-out.log
  install_package_from_npm:
    npm.installed:
      - name: "@massivexp/api@{{ package_version }}"
      - require:
          - file: /usr/local/lib/node_modules/npm/npmrc
  /usr/local/etc/process.yml:
    file.managed:
      - context:
        package_name: "api"
        http_cors_origin: "https://www.massivexp.com"
  pm2 start --hp / /usr/local/etc/process.yml:
    cmd.run:
      - unless: pm2 jlist --hp / | jq .[0].pm2_env.version | grep {{ package_version }}
