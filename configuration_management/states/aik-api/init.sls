# (1)
/var/sites/aik-portal:
  file.directory: []

# (2)
aik-portal-repo:
  git.latest:
    - name: https://github.com/dvlopez9811/aik-portal-backend
    - branch: master
    - target: /var/sites/aik-portal
    - require:
      - file: /var/sites/aik-portal

# (3)
aik-portal-npm-install:
  cmd.wait:
    - name: 'npm install'
    - cwd: /var/sites/aik-portal
    - watch:
      - git: aik-portal-repo

# (4)
/etc/systemd/system/node-aik-portal.service:
  file.managed:
    - contents: |
      [Unit]
      After=network.target

      [Service]
      ExecStart=/usr/local/bin/npm start
      WorkingDirectory=/var/sites/aik-portal
      Restart=always
      Environment=NODE_ENV=production

      [Install]
      WantedBy=multi-user.target

# (5)
node-aik-portal-daemon-reload:
  module.run:
    - name: service.systemctl_reload
    - watch:
      - file: /etc/systemd/system/node-aik-portal.service

# (6)
node-aik-portal-service:
  service.running:
    - name: node-aik-portal
    - enable: True
    - watch:
      - git: aik-portal-repo
      - file: /etc/systemd/system/node-aik-portal.service
