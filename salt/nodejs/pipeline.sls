{% set package_version = "0.0.40" %}

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
  pm2 start --hp / /usr/local/etc/process.yml:
    cmd.run:
      - unless: pm2 jlist --hp / | jq .[0].pm2_env.version | grep {{ package_version }}
