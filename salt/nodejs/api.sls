{% set package_version = "0.0.6" %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/api-error.log
          - /.pm2/logs/api-out.log
  install_package_from_npm:
    npm.installed:
      - name: "@massivexp/api@{{ package_version }}"
  /usr/local/etc/process.yml:
    file.managed:
      - context:
        package_name: "api"
        http_cors_origin: "https://www.massivexp.com"
