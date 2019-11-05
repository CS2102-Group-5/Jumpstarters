/**
The list of valued organizations, where a valued organization is defined as:
The organization has at least 5 successful projects
Has at least 15 of creators under the organization
The unique countries which the projects under the organization ships to is at least 5 countries.
**/

SELECT Creator.Organization FROM Creator
INNER JOIN Tags ON (Creator.user_name = Tags.user_name)
INNER JOIN Projects ON (Tags.project_id = Projects.id)
WHERE Projects.project_status = 'success'
GROUP BY Creator.Organization;


HAVING COUNT(*) >= 5