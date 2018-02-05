## Usage:
## update_qpid.sh  qpid_configure_file_path  qpid_handler_file_patch qpid_broker_ip
## update_qpid.sh /var/www/errata_rails/config/initializers/credentials/qpid.rb   /var/www/errata_rails/lib/message_bus/qpid_handler.rb  10.8.248.33

backup_file() {
  if [ -e "${1}_bak" ];then
    echo "==The backup file has been existed=="
  else
    echo "==Backuping the qpid setting file=="
    echo cp ${1} ${1}_bak
    cp ${1} ${1}_bak
  fi
}

if [ "$#" -eq 3 ];then
  qpid_server_setting_file=$1
  qpid_handler_file=$2
  qpid_server=$3
else
  echo "Error, please input the qpid_server_setting_file, qpid_handler_file path you want to update, and the broker url"
  echo "The command can like:"
  echo "update_qpid.sh /var/www/errata_rails/examples/ruby/message_bus/qpid_configuration.rb /var/www/errata_rails/examples/ruby/message_bus/handler.rb ampq://10.8.241.108:5672"
  exit
fi

echo "=====Before update, just backup the files====="
for file in ${qpid_server_setting_file} ${qpid_handler_file}
do
  backup_file ${file}
done
echo "=====Update the qpid server setting======"
echo sed -i "s/qpid.test.engineering.redhat.com/${qpid_server}/g" ${qpid_server_setting_file}
sed -i "s/qpid.test.engineering.redhat.com/${qpid_server}/g" ${qpid_server_setting_file}
echo sed -i "s/5671/5672/g"  ${qpid_server_setting_file}
sed -i "s/5671/5672/g"  ${qpid_server_setting_file}

echo "=====Update the qpid handler authentication mode====="
echo sed -i "s/GSSAPI/ANONYMOUS/g" ${qpid_handler_file}
sed -i "s/GSSAPI/ANONYMOUS/g" ${qpid_handler_file}

echo "=====Update the server hostname to ip====="
echo sed -i "s/ErrataSystem::SERVICE_NAME/\"0.0.0.0\"/g" ${qpid_handler_file}
sed -i "s/ErrataSystem::SERVICE_NAME/\"0.0.0.0\"/g" ${qpid_handler_file}
echo "=================Update Done================="
echo "==============Restart the service============"
echo /etc/init.d/httpd24-httpd restart
/etc/init.d/httpd24-httpd restart
echo /etc/init.d/delayed_job restart
/etc/init.d/delayed_job restart
echo /etc/init.d/qpid_service restart
/etc/init.d/qpid_service restart
echo /etc/init.d/messaging_service restart
/etc/init.d/messaging_service restart
