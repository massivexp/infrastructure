{% set package_version = "0.0.12" %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/massivexp-error.log
          - /.pm2/logs/massivexp-out.log
  install_package_from_npm:
    npm.installed:
      - name: "@massivexp/massivexp@{{ package_version }}"
  /usr/local/etc/process.yml:
    file.managed:
      - context:
        package_name: "massivexp"
        application_working_directory: ""
        application_entry: "dist/massivexp/server/main.js"
