{% set package_version = "0.0.10" %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/api-error-0.log
          - /.pm2/logs/api-out-0.log
  install_package_from_npm:
    npm.installed:
      - name: "@massivexp/massivexp@{{ package_version }}"
  /usr/local/etc/process.yml:
    file.managed:
      - context:
        package_name: "massivexp"
        application_entry: "dist/massivexp/server/main.js"
