--- 
include: 
  - nodejs

aik-ui: 
  git.latest: 
    - 
      name: "https://github.com/dvlopez9811/aik-portal-frontend"
    - 
      target: /srv/app

install_npm_dependencies: 
  npm.bootstrap: 
    - 
      name: /srv/app/aik-app-ui

/etc/systemd/system/node-aik-app-ui.service: 
  file.managed: 
    - 
      contents: |
          [Unit]
          Description=AIK Frontned
          After=network.target
          
          [Service]
          ExecStart=/usr/bin/node /srv/app/aik-app-ui/server.js
          Restart=always
          RestartSec=10
          StandardOutput=syslog
          StandardError=syslog
          SyslogIdentifier=aik-app-ui
          Environment=NODE_ENV=production
          EnvironmentFile=/etc/environment
          
          [Install]
          WantedBy=multi-user.target

node-aik-app-ui-daemon-reload: 
  module.run: 
    - 
      name: service.systemctl_reload
    - 
      watch: 
        - 
          file: /etc/systemd/system/node-aik-app-ui.service

node-aik-app-ui-service: 
  service.running: 
    - 
      name: node-aik-app-ui
    - 
      enable: true
    - 
      watch: 
        - 
          file: /etc/systemd/system/node-aik-app-ui.service
