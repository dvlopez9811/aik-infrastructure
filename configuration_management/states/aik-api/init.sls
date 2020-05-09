
include:
    - nodejs

aik-ui:
    git.latest:
     - name: https://github.com/dvlopez9811/aik-portal-backend
     - target: /srv/app

install_npm_dependencies:
    npm.bootstrap:
      - name: /srv/app/aik-app-api

run_aik_portal_frontend:
    cmd.run:
      - name: "node /srv/app/aik-app-api/server.js" 
