{% set port = 8088 %}

nginx-package:
  pkg.installed:
    - name: nginx

nginx-root-dir:
  file.directory:
    - name: /var/www/html
    - user: root
    - group: root
    - mode: 755

nginx-index-file:
  file.managed:
    - name: /var/www/html/index.html
    - source: salt://nginx/index.html.j2
    - template: jinja
    - context:
        minion_id: {{ grains['id'] }}
    - user: root
    - group: root
    - mode: 644

nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/custom_site
    - source: salt://nginx/config.sls
    - template: jinja
    - context:
        listen_port: {{ port }}

nginx-enable:
  file.symlink:
    - name: /etc/nginx/sites-enabled/custom_site
    - target: /etc/nginx/sites-available/custom_site

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: nginx-conf
      - file: nginx-index-file
