#1. get the bugs list
bugs=$(echo ${bugs_link} | cut -d "=" -f 2 | sed  "s/&list_id//" | sed 's/%2C/ /g')
echo "====Bugs: ${bugs}==================="
#2. set the bugzilla username, confluence username
bugzilla_username="${username}@redhat.com"
confluence_username=${username}
echo "The bugzilla account is ${bugzilla_username}, the confluence account is ${confluence_username}"
#3. first install the confluence-py and bugzilla module, then get and run script to generate the conflunce content for the bug page, finally create the page on confluence
sudo pip install confluence-py
sudo pip install bugzilla
sudo pip install requests
if [[ -e Automation-Scripts ]]; then
	echo "====Removing the useless dir============"
	rm -rf Automation-Scripts
	echo "=============DONE======================="
fi
echo "======Git clone the scripts=============== "
git clone https://github.com/testcara/Automation-Scripts.git
if [[ -e Automation-Scripts ]];then
	echo "======================DONE=================="
else
	echo "=============FAILED to get the file. Exit With error=========="
	exit 1
fi
dir=$(pwd)
cd ${dir}/Automation-Scripts
git checkout python
if [[  -e "${dir}/Automation-Scripts/rc_bug_regression" ]]; then
	echo "=======The target file has been found==============="
	cd ${dir}/Automation-Scripts/rc_bug_regression
	echo "=======Generating the confluence page content for bugs============"
	sudo python generate_confluence_page_for_bugs.py ${bugzilla_username} ${password} ${bugs}
	if [[ -e 'content.txt' ]]; then
		echo "==============Done========================="
	else
		echo "==========FAILED to generate the content. Exit with error"
		exit 1
	fi
fi
echo "==========Adding page to confluence==========="
result=$(sudo confluence-cli --wikiurl="https://docs.engineering.redhat.com" -u ${confluence_username} -p ${password}  addpage -n "Bugs Regression Testing - ${et_build_name}" -s ${space} -f 'content.txt')
if [[ ${result} =~ "https" ]]; then
	echo "=========================Done: confluence page generated===================="
	echo "====URL:https://docs.engineering.redhat.com/display/$5/Bugs Regression Testing - $4"
else
	echo "========FAILED: Creating page. Exit with error.===================="
	echo "=========Error info:============"
	echo ${result}
	exit 1
fi
