require 'redmine'

Redmine::Plugin.register :redmine_wiki_issue_details do
  name 'Redmine Wiki Issue Details plugin'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author_url 'http://www.littlestreamsoftware.com'
  description 'This plugin adds a wiki macro to make it easier to list the details of issues on a wiki page.'
  version '0.1.0'
  requires_redmine :version_or_higher => '2.1.0'

  Redmine::WikiFormatting::Macros.register do
    desc "Display a list of issues.  Examples:\n\n" +
         "!{{issue_list(100,101)}}\n\n" +
         "<ul><li>Issue subject - Task #100 (Assignee)</li><li>Some Other Issue - Bug #101 (Assignee)</li></ul>"
    macro :issue_list do |obj,args|
	 ret = '<ul>'
         args.each {|id|
	    issue = Issue.visible.find_by_id(id)
	    if issue
                assigned="Unassigned"
		if issue.assigned_to_id
		    assigned=issue.assigned_to.name
		end
		ret += "<li>#{link_to_issue(issue)} (#{assigned})</li>"	
	    end	
  	 }
	 ret += '</ul>'
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Display an issue and it's details.  Examples:\n\n" +
      "  !{{issue_details(100)}}\n\n" +
      "  Digitized 24 hour firmware - Bug #391 Robust disintermediate customer loyalty - 25.23 hours"
    macro :issue_details do |obj, args|
      issue_id = args[0]
      issue = Issue.visible.find_by_id(issue_id)

      return '' unless issue

      if Redmine::AccessControl.permission(:view_estimates) && !User.current.allowed_to?(:view_estimates, issue.project)
        # Check if the view_estimates permission is defined and the user
        # is allowed to view the estimate
        estimates = ''
      elsif issue.estimated_hours && issue.estimated_hours > 0
        estimates = "[<b>#{l_hours(issue.estimated_hours)}</b>]"
      else
        estimates = "- <strong>#{l(:redmine_wiki_issue_details_text_needs_estimate)}</strong>"
      end

      open_tag = issue.closed? ? '<span style="text-decoration: line-through;">' : ''
      close_tag = issue.closed? ? '</span>' : ''

      content = open_tag + link_to_issue(issue) + ' ' +
        estimates + ' ' + "(#{h(issue.status)}, #{issue.done_ratio}%)" + close_tag

      content.html_safe
    end
  end
end
