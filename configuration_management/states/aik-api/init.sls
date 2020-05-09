# (1)
/srv/app:
  file.directory: []

# (2)
mynodeapp-repo:
  git.latest:
    - name: https://github.com/dvlopez9811/aik-portal-backend
    - branch: master
    - target: /srv/app
    - require:
      - file: /srv/app

# (3)
mynodeapp-npm-install:
  cmd.wait:
    - name: 'npm install'
    - cwd: /srv/app/aik-app-api
    - watch:
      - git: mynodeapp-repo

# (4)
/etc/systemd/system/node-mynodeapp.service:
  file.managed:
    - contents: |
       [Unit]
       Description=RocketChat Server
       After=network.target remote-fs.target nss-lookup.target mongod.target apache2.target

       [Service]
       ExecStart=/usr/bin/node /srv/app/aik-app-api/server.js
       Restart=always
       RestartSec=10
       StandardOutput=syslog
       StandardError=syslog
       SyslogIdentifier=rocketchat
       Environment=NODE_ENV=production

       [Install]
       WantedBy=multi-user.target

# (5)
node-mynodeapp-daemon-reload:
  module.run:
    - name: service.systemctl_reload
    - watch:
      - file: /etc/systemd/system/node-mynodeapp.service

# (6)
node-mynodeapp-service:
  service.running:
    - name: node-mynodeapp
    - enable: True
    - watch:
      - git: mynodeapp-repo
      - file: /etc/systemd/system/node-mynodeapp.service
