#!/bin/sh
# log in the ET server, download the automation scripts, run the script to do the update. 
ssh -tt root@${1} << EOF
if [ -e Automation-Scripts ];then
  rm -rf Automation-Scripts
  echo "=====deleting the obsoleted files====="
fi
echo "=====git the repo====="
git clone  https://github.com/testcara/Automation-Scripts.git
cd Automation-Scripts
echo "=====git checkout branch====="
git checkout  shell_scripts
echo "=====updating umb====="
./update_umb_bus.sh  /var/www/errata_rails/config/initializers/credentials/message_bus.rb /var/www/errata_rails/lib/message_bus/handler.rb ${2}
./update_umb_bus.sh  /var/www/errata_rails/examples/ruby/message_bus/umb_configuration.rb /var/www/errata_rails/examples/ruby/message_bus/handler.rb ${2}
echo "=====updating qpid====="
./update_qpid.sh /var/www/errata_rails/config/initializers/credentials/qpid.rb   /var/www/errata_rails/lib/message_bus/qpid_handler.rb  ${3}
rm -rf /tmp/${dir}
exit
exit
EOF
