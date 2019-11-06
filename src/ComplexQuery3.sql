/**
The list of valued organizations, where a valued organization is defined as:
The organization has at least 5 successful projects
Has at least 15 of creators under the organization
The unique countries which the projects under the organization ships to is at least 5 countries.
**/
with orgsCountry as (
	select c.organization, SI.country_name from creator c --
	INNER JOIN Tags t ON (c.user_name = t.user_name)
	INNER JOIN Projects p ON (t.project_id = p.id)
	inner join shipping_info SI on (p.id = SI.project_id)
	where c.organization is not null
	group by c.organization, SI.country_name
)
SELECT c.organization FROM Creator c -- extract only c.organization at the end
INNER JOIN Tags ON (c.user_name = Tags.user_name)
INNER JOIN Projects ON (Tags.project_id = Projects.id)
INNER JOIN History ON (Projects.id = History.project_id)
WHERE History.project_status = 'success' and c.Organization is not null -- filer successfuls and lone wolves
GROUP BY c.Organization
HAVING COUNT(*) >= 5 -- at least 5 successfuls
except -- minus away orgs with <15 creators
select c.organization from creator c
WHERE c.organization is not null
group by c.organization
having count(*) < 15
except -- minus orgs that ship to <5 countries
select o.organization from orgsCountry o
group by o.organization
having count(*) < 5
;