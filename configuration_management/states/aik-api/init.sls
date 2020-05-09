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
       After=network.target

       [Service]
       ExecStart=/usr/local/bin/npm start
       WorkingDirectory=/srv/app/aik-app-api
       Restart=always
       Environment=NODE_ENV=production

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
