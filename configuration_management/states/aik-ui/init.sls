include:
     - nodejs

aik-ui:
    git.latest:
     - name: https://github.com/dvlopez9811/aik-app-api-frontend
     - target: /srv/app

install_npm_dependencies:
    npm.bootstrap:
     - name: /srv/app/aik-app-ui

# (4)
/etc/systemd/system/node-aik-app-ui.service:
    file.managed:
     - contents: |
       [Unit]
       Description=AIK Frontend
       After=network.target remote-fs.target nss-lookup.target
       
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

# (5)
node-aik-app-ui-daemon-reload:
    module.run:
     - name: service.systemctl_reload
     - watch:
       - file: /etc/systemd/system/node-aik-app-ui.service

# (6)
node-aik-app-ui-service:
    service.running:
     - name: node-aik-ui-api
     - enable: True
     - watch:
       - git: aik-app-ui-repo
       - file: /etc/systemd/system/node-aik-app-ui.service
