#!/bin/sh


echo "/tmp/bin  start"
ls  -l /tmp/bin/
file /tmp/bin/*
echo "/tmp/bin  end"

# exit script on any error
set -e
echo "setting up initial configurations"

if [ ! -f "$BNBD_HOME/config/config.toml" ];
then
  cp -r /tmp/config $BNBD_HOME/config
fi

echo "/usr/local/bin/  start"
ls -l /usr/local/bin/
file /usr/local/bin/*
echo "/usr/local/bin/  end"


echo "configuration complete  ---- starting..."

#exec  /usr/local/bin/bnbchaind start  --home $BNBD_HOME
exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
