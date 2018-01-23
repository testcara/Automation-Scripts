## Usage:
## update_umb_bus.sh  umb_configure_file_path  umb_handler_file_patch umb_broker_ip
## update_umb_bus.sh  /var/www/errata_rails/examples/ruby/message_bus/umb_configuration.rb /var/www/errata_rails/examples/ruby/message_bus/handler.rb 10.8.241.108:5672
## update_umb_bus.sh  /var/www/errata_rails/config/initializers/credentials/message_bus.rb /var/www/errata_rails/lib/message_bus/handler.rb 10.8.241.108:5672

backup_file() {
  if [ -z "${1}_bak" ];then
    echo "==The backup file has been existed=="
  else
    echo "==Backuping the umb setting file=="
    echo cp ${1} ${1}_bak
    cp ${1} ${1}_bak
  fi
}

if [ "$#" -eq 3 ];then
  umb_server_setting_file=$1
  umb_handler_file=$2
  umb_server=$3
else
  echo "Error, please input the umb_server_setting_file, umb_handler_file path you want to update, and the broker url"
  echo "The command can like:"
  echo "update_umb_bus.sh /var/www/errata_rails/examples/ruby/message_bus/umb_configuration.rb /var/www/errata_rails/examples/ruby/message_bus/handler.rb ampq://10.8.241.108:5672"
  exit
fi

echo "=====Before update, just backup the files====="
for file in ${umb_server_setting_file} ${umb_handler_file}
do
  backup_file ${file}
done
echo "=====Update the umb server setting======"
for umb_outdated_server in 'messaging-devops-broker01.web.stage.ext.phx2.redhat.com:5671' 'messaging-devops-broker01.qe.stage.ext.phx2.redhat.com:5671'
do
  echo sed -i "s/${umb_outdated_server}/${umb_server}/g" ${umb_server_setting_file}
  sed -i "s/${umb_outdated_server}/${umb_server}/g"  ${umb_server_setting_file}
  echo sed -i "s/amqps/amqp/g"  ${umb_server_setting_file}
  sed -i "s/amqps/amqp/g"  ${umb_server_setting_file}
done
echo "=====Disable the CA parts of the umb server setting====="
for cert_file in 'CLIENT_CERT' 'CLIENT_KEY' 'CERT_NAME'
do
  echo sed -i "/${cert_file}/s/^/#/" ${umb_server_setting_file}
  sed -i "/${cert_file}/s/^/#/"  ${umb_server_setting_file}
done


echo "=====Before update, just backup the handler file====="
echo "=====Disable the CA parts of the umb handler setting====="
for cert_file in '@cert' '@key'
do
  echo sed -i "/${cert_file}/s/^/#/"  ${umb_handler_file}
  sed -i "/${cert_file}/s/^/#/"  ${umb_handler_file}
done

echo "=====Disable the redundant 'end'====="
for message in "Using cert #{@cert} & key #{@key}" "messenger.private_key = @key"
do
  previous_line_number=$(grep -n "${message}" ${umb_handler_file} | cut -d ":" -f 1)
  end_line_number=$((${previous_line_number}+1))
  echo sed -i "${end_line_number}s/^/#/" ${umb_handler_file}
  sed -i "${end_line_number}s/^/#/" ${umb_handler_file}
done

echo "=====Update the server hostname to ip====="
echo sed -i "s/ErrataSystem::SERVICE_NAME/\"0.0.0.0\"/g" ${umb_handler_file}
sed -i "s/ErrataSystem::SERVICE_NAME/\"0.0.0.0\"/g" ${umb_handler_file}
echo "=================Update Done================="
echo "==============Restart the service============"
echo /etc/init.d/httpd24-httpd restart
/etc/init.d/httpd24-httpd restart
echo /etc/init.d/messaging_service restart
/etc/init.d/messaging_service restart
