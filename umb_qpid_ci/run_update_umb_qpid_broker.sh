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
cd umb_qpid_ci
echo "=====updating umb and qpid====="
./update_umb_qpid.sh -q $2 -u $3
exit
exit
EOF
