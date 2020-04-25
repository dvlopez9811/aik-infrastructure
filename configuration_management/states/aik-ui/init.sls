
include:
    - git
    - nodejs

aik-ui:
    git.latest:
     - name: https://github.com/dvlopez9811/aik-portal-frontend
     - target: /srv/app
    require:
     - pgk: git

install_npm_dependencies:
    npm.bootstrap:
      - name: /srv/app/aik-app-ui

run_aik_portal_frontend:
    cmd.run:
      - name: "nohup node /srv/app/aik-app-ui/server.js > /dev/null 2>&1 &" 
