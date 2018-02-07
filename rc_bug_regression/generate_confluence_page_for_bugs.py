#/bin/python2
import pprint
import bugzilla
import sys


def get_bug_and_format_bug(bug_id):
	bug_result = ""
	bzapi = bugzilla.Bugzilla("bugzilla.redhat.com")
	bug = bzapi.getbug(bug_id)
	qe_flag = False
	for flag in bug.flags:
		if flag['name'] == "qe_test_coverage":
			qe_flag = True
			qe_bug_flag = flag['status']
		else:
			next
	bug_flag = qe_bug_flag if qe_flag else ""
		

	formatted_bug = [ bug.id, bug.summary, bug.component, bug.status, bug.severity, bug.priority, bug_flag, bug.qa_contact, bug_result ]
	return formatted_bug

def get_bugs_and_format_bugs(bugs_list):
	formatted_bugs =[]
	for bug in bugs_list:
		formatted_bugs.append(get_bug_and_format_bug(bug))
	return formatted_bugs

def generate_page_content(formmatted_bugs_list):
	table_column = ['ID', 'Summary', 'Component', 'Status', 'Severity', 'Priority', 'Flags', 'QAOwner', 'Result']
	head_row = ""
	for column_name in table_column:
		head_row += "<th colspan='1'>" + column_name +"</th>"
	headrow_html = "<tr>" + head_row + "</tr>"
	bug_rows_html = ""
	for formatted_bug in formmatted_bugs_list:
		bug_rows_html += generate_bug_content(formatted_bug)
	table_content = "<table><tbody>" + headrow_html + bug_rows_html + "</tbody></table>"
	return table_content

def write_page_file(table_content):
	f = open('content.txt','w')
	f.write(table_content)
	f.close


def generate_bug_content(formatted_bug):
	bug_row = ""
	bug_id = str(formatted_bug[0])
	bug_details = formatted_bug[1:]
	bug_id_td_html = '<td><a href=' + '"https://bugzilla.redhat.com/show_bug.cgi?id=' + bug_id + '">' + bug_id + "</a></td>"
	for bug_item in bug_details:
		bug_row += "<td>" + bug_item + "</td>"
	bug_row_html = "<tr>" + bug_id_td_html + bug_row + "</tr>"
	return bug_row_html


def generate_confluence_page_for_bugs(bugs):
	formatted_bugs_list = get_bugs_and_format_bugs(bugs)
	html = generate_page_content(formatted_bugs_list)
	write_page_file(html)


if __name__== "__main__":
	bugs_list = []
	if len(sys.argv) == 2:
		bugs_list = sys.argv[1]
	else:
		bugs_list = sys.argv[2:]
	print bugs_list
	print type(bugs_list)

	generate_confluence_page_for_bugs(bugs_list)