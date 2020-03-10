{% set package_version = "0.0.12" %}

extend:
  /usr/local/etc/filebeat.yml:
    file.managed:
      - context:
        specific_log_files:
          - /.pm2/logs/pipeline-error.log
          - /.pm2/logs/pipeline-out.log
  install_package_from_npm:
    npm.installed:
      - name: "@massivexp/pipeline@{{ package_version }}"
  /usr/local/etc/process.yml:
    file.managed:
      - context:
        package_name: "pipeline"
        http_cors_origin: ""
