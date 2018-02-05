#!/bin/sh
# log in the ET server, download the automation scripts, run the script to do the update. 
ssh -tt root@${1} << EOF
git clone  https://github.com/testcara/Automation-Scripts.git
cd Automation-Scripts
git branch -a
git checkout  shell_scripts
./update_umb_bus.sh  /var/www/errata_rails/config/initializers/credentials/message_bus.rb /var/www/errata_rails/lib/message_bus/handler.rb ${2}
./update_umb_bus.sh  /var/www/errata_rails/examples/ruby/message_bus/umb_configuration.rb /var/www/errata_rails/examples/ruby/message_bus/handler.rb ${2}
./update_qpid.sh /var/www/errata_rails/config/initializers/credentials/qpid.rb   /var/www/errata_rails/lib/message_bus/qpid_handler.rb  ${3}
exit
exit
EOF
