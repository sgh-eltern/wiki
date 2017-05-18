#!/usr/bin/env bash

# generated from "<%= template %>"

mysqldump \
    --host="$(mysqlbackups "<%= config['source_db'] %>" | head -1)" \
    --user="<%= config['source_user'] %>" \
    --password="<%= config['source_password'] %>" \
  "<%= config['source_db'] %>" \
| mysql \
    --host=rdbms \
    --user="<%= config['target_user'] %>" \
    --password="<%= config['target_password'] %>" \
  "<%= config['target_db'] %>"
EOF

chmod +x deployment/bin/"<%= config['self'] %>"
