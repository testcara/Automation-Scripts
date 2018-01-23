backup_file() {
  if [ -z "${1}_bak" ];then
    echo "==The backup file has been existed=="
  else
    echo "==Backuping the umb setting file=="
    echo cp ${1} ${1}_bak
    cp ${1} ${1}_bak
  fi
}
umb_server_setting_file=/var/www/errata_rails/config/initializers/credentials/message_bus.rb
umb_handler_file='/var/www/errata_rails/lib/message_bus/handler.rb'

echo "=====Before update, just backup the files====="
for file in ${umb_server_setting_file} ${umb_handler_file}
do
  backup_file ${file}
done
echo "=====Update the umb server setting======"
echo sed -i "s/messaging-devops-broker01.web.qa.ext.phx1.redhat.com:5671/$1/g" ${umb_server_setting_file}
sed -i "s/messaging-devops-broker01.web.qa.ext.phx1.redhat.com:5671/$1/g"  ${umb_server_setting_file}
echo sed -i "s/messaging-devops-broker02.web.qa.ext.phx1.redhat.com:5671/$1/g"  ${umb_server_setting_file}
sed -i "s/messaging-devops-broker02.web.qa.ext.phx1.redhat.com:5671/$1/g" ${umb_server_setting_file}
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
echo "=================Update Done================="
echo "==============Restart the service============"
echo /etc/init.d/httpd24-httpd restart
/etc/init.d/httpd24-httpd restart
echo /etc/init.d/messaging_service restart
/etc/init.d/messaging_service restart
