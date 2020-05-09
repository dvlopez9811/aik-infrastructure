include:
    - nodejs

aik-ui:
    git.latest:
      - name: https://github.com/dvlopez9811/aik-portal-frontend
      - target: /srv/app

install_npm_dependencies:
    npm.bootstrap:
      - name: /srv/app/aik-app-ui
# (4)
/etc/systemd/system/aik-app-ui.service:
    file.managed:
    - contents: |
      [Unit]
      Description=AIK Backend
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
aik-app-ui-daemon-reload:
  module.run:
    - name: service.systemctl_reload
    - watch:
      - file: /etc/systemd/system/aik-app-ui.service

# (6)
node-mynodeapp-service:
  service.running:
    - name: aik-app-ui
    - enable: True
    - watch:
      - file: /etc/systemd/system/aik-app-ui.service
