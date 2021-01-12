#!/bin/sh

# exit script on any error
set -e
echo "setting up initial configurations"

if [ ! -f "$BNBD_HOME/config/config.toml" ];
then

  shell="ls /tmp/config" #查看根目录下所有文件
  $shell  #执行上面的字符串命令


fi


echo "configuration complete  ---- starting..."

exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
