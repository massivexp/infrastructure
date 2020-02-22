{% set package_version = "0.0.1" %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/api-error-0.log
          - /.pm2/logs/api-out-0.log
  install_package_from_npm:
    cmd.run:
      - name: npm install @massivexp/api@{{ package_version }} && echo "ok" > .installed_api_{{ package_version }}
      - creates: .installed_api_{{ package_version }}
  /usr/local/etc/process.yml:
    file.managed:
      - defaults:
        package_name: "api"
        http_cors_origin: ""
