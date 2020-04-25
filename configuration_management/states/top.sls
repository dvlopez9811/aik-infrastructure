base:
  '*':
    - yum-s3
  'roles:frontend':
    - match: grain
    - aik-ui
    - nodejs

  'roles:backend':
    - match: grain
    - aik-api
    - nodejs

  'roles:jenkins':
    - match: grain
    - jenkins
    - docker
    - packer
