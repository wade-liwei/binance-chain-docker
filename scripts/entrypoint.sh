#!/bin/sh

# exit script on any error
set -e
echo "setting up initial configurations"

if [ ! -f "$BNBD_HOME/config/config.toml" ];
then
  cp -r /tmp/config $BNBD_HOME/config

  ls /usr/local/bin/
fi


echo "configuration complete  ---- starting..."

exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
