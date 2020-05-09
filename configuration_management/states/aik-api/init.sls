include:
     - nodejs

aik-ui:
    git.latest:
     - name: https://github.com/dvlopez9811/aik-app-api-backend
     - target: /srv/app

install_npm_dependencies:
    npm.bootstrap:
     - name: /srv/app/aik-app-api

# (4)
/etc/systemd/system/node-aik-app-api.service:
    file.managed:
     - contents: |
       [Unit]
       Description=AIK Backend
       After=network.target remote-fs.target nss-lookup.target
       
       [Service]
       ExecStart=/usr/bin/node /srv/app/aik-app-api/server.js
       Restart=always
       RestartSec=10
       StandardOutput=syslog
       StandardError=syslog
       SyslogIdentifier=aik-app-api
       Environment=NODE_ENV=production
       EnvironmentFile=/etc/environment
       
       [Install]
       WantedBy=multi-user.target
# (5)
node-aik-app-api-daemon-reload:
    module.run:
     - name: service.systemctl_reload
     - watch:
       - file: /etc/systemd/system/node-aik-app-api.service

# (6)
node-aik-app-api-service:
    service.running:
     - name: node-aik-app-api
     - enable: True
     - watch:
       - git: aik-app-api-repo
       - file: /etc/systemd/system/node-aik-app-api.service
