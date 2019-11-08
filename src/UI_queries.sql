
/*HOME PAGE */

/*
Get top 3 projects with highest ratings
*/
SELECT p.id, SUM(r.rating) FROM Projects p INNER JOIN Rates r ON r.project_id = p.id 
INNER JOIN History h ON h.project_id = p.id 
WHERE (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) 
AND h.project_status = 'Ongoing' 
GROUP BY p.id 
ORDER BY SUM(r.rating) DESC, p.project_name LIMIT(3);

/*
Check from the set of latest history for each project id, if status is 'Ongoing' and end date > current_timestamp then check total pledges
if sum(pledges) > goal --> Successful
if sum(pledges) < goal --> Unsuccessful
*/
WITH X AS (SELECT h.goal, h.time_stamp, h.project_id, h.project_status FROM History h WHERE (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND h.end_date < CURRENT_TIMESTAMP AND h.project_status = 'Ongoing') 
UPDATE History h SET project_status = 
CASE 
WHEN (SELECT true FROM X INNER JOIN Pledges p ON p.project_id = X.project_id WHERE h.project_id = X.project_id AND h.time_stamp = X.time_stamp HAVING h.goal <= COALESCE(SUM(p.pledge))) THEN 'Successful' 
WHEN (SELECT true FROM X INNER JOIN Pledges p ON p.project_id = X.project_id WHERE h.project_id = X.project_id AND h.time_stamp = X.time_stamp HAVING h.goal > COALESCE(SUM(p.pledge))) THEN 'Unsuccessful'
ELSE 'Ongoing' END 
WHERE (h.project_id , h.time_stamp) IN (SELECT project_id,time_stamp FROM X);

/*
Get projects with is in funder's preferneces and ships to country, rank top 3 the alphabetical
*/
WITH X AS (
	SELECT COALESCE(SUM(r.rating),0) as rating, r.project_id  as id FROM Rates r GROUP BY r.project_id UNION SELECT 0 as rating, p.id FROM Projects p WHERE p.id NOT IN (SELECT DISTINCT project_id FROM Rates)
	) 
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, X.rating, p.project_type FROM Projects p 
INNER JOIN Media m ON m.project_id = p.id 
INNER JOIN Funder f ON p.project_type = ANY (f.preferences) 
INNER JOIN X ON X.id = p.id 
WHERE m.description = 'about' AND f.user_name = $user_name 
AND EXISTS (SELECT 1 FROM Shipping_info s where s.project_id = p.id AND country_name = $country) 
ORDER BY X.rating DESC, p.project_name LIMIT(3);

---------------------------------------------------------------------------------------------------------------------------------
/*
Projects page
--> if user is logged in, use functons to get projects, else query as follows
*/

/*
Retrieve projects by type
*/
var type_sql = (user_name) ? "SELECT * FROM get_projects_info_by_type('"+ country +"','"+ type +"');" : "SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date, p.project_location FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND p.project_type = '" + type + "' ORDER BY p.project_name;"

/*
Retrieve projects by tags
*/
var tags_sql = (user_name && tags) ? "SELECT * FROM get_projects_info_by_tags('"+ country +"','"+ tags +"');" : "SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date, p.project_location FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id INNER JOIN tags t ON t.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND t.tag_name = '" + tags + "'ORDER BY p.project_name;";

/*
Retrieve projects
*/
var project_sql = (user_name) ? "SELECT * FROM get_projects_info('"+ country +"');" : "SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date, p.project_location FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) ORDER BY p.project_name;"


---------------------------------------------------------------------------------------------------------------------------------
/* VIEW PROJECT */

/* TO DISPLAY */
/*
Retrieving data to display for projects
*/
var sql_details = 'SELECT * FROM Projects WHERE id = ' + id + ';';
var sql_media = 'SELECT link, description FROM Media WHERE project_id = ' + id + 'ORDER BY description;';
/** Get latest history */
var sql_history = 'select h.*, CASE WHEN extract(day from (h.end_date  - CURRENT_TIMESTAMP))<=0 THEN 0 ELSE extract(day from (h.end_date  - CURRENT_TIMESTAMP)) END as days_to_go from history h WHERE (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND h.project_id = ' + id + ';';
var sql_shipping_info = 'select country_name from shipping_info WHERE project_id = ' + id + ';';
var sql_total_pledge = 'select COALESCE(SUM(pledge),0) AS total_pledge, COUNT(*) AS backers FROM Pledges WHERE project_id = ' + id + ';';
var sql_comments = 'select * from Comments WHERE project_id = ' + id + 'ORDER BY time_stamp DESC LIMIT(5);';
var sql_tags = 'select tag_name from tags WHERE project_id = ' + id + ';';
var sql_currencies = 'select currency_name as cur FROM Country ORDER BY currency_name'
/*
If user is logged in, retrieve details for actions done by user
*/
sql_pledge_check = "SELECT pledge FROM Pledges WHERE user_name = '" + user_name + "' AND project_id = " + id 
sql_follow_check = "SELECT true FROM Follows WHERE funder = '" + user_name + "' AND projects_followed = " + id
sql_rates_check = "select rating FROM rates WHERE project_id = " + id + "AND user_name = '" + user_name + "'";
sql_shipping_check = "SELECT CASE WHEN ((SELECT true FROM Shipping_info s WHERE s.project_id =" + id+ " AND s.country_name = '" + country + "') OR (SELECT (COUNT(*) = 0) FROM Shipping_info s WHERE s.project_id = "+ id +")) THEN true ELSE false END;";


/* ON CLICK OF BUTTON (eg. to pledge, to rate, to follow etc)*/

/*
Inserting pledges
*/
"INSERT INTO Pledges VALUES(" + id + ",'" + user_name + "'," +"(select exchange_rate FROM currencypair where base_currency ='" + currency + "' AND quote_currency = 'USD')*" + pledge + ",'" + dateTime + "');";
/*
Inserting into follows
*/
"INSERT INTO Follows VALUES(" + id + ",'" + user_name + "');";

/*
Inserting into rates
*/
"INSERT INTO Rates VALUES('" + user_name + "'," + id + "," + req.body.optradio + ");";

/*
Cancel pledge
*/
"DELETE FROM Pledges WHERE user_name" + user_name + "' AND project_id  = " + id;

/*
Unfollow
*/
"DELETE FROM Follows WHERE funder = '" + user_name + "' AND projects_followed = " + id;

/*
Unrate
*/
"DELETE FROM Rates WHERE user_name = '" + user_name + "' AND project_id = " + id;

---------------------------------------------------------------------------------------------------------------------------------

/*USER PAGE*/

/*
Check for creator
*/
"SELECT true FROM Creator WHERE user_name = '" + user_name + "'"

/*
Retrieve project infomration for creator
*/
"SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND p.user_name = '" + user_name + "' ORDER BY p.project_name;"

/*
Retrieve information of projects which funder follows
*/
"SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE (h.project_id,h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND m.description = 'about' AND p.id IN (SELECT projects_followed FROM Follows WHERE Funder = '" + user_name + "') ORDER BY p.project_name;";

/*
Retrieve information of projects which funder pledges
*/
"SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h,project_status FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE (h.project_id,h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND m.description = 'about' AND p.id IN (SELECT project_id FROM Pledges WHERE user_name = '" + user_name + "') ORDER BY p.project_name;"

---------------------------------------------------------------------------------------------------------------------------------

/*START PROJECT*/

/*
Insert into projects table
*/
"INSERT INTO Projects VALUES" + "(" + id + ",'" + user_name + "','" + projectName + "','" + projectType + "','" + description + "','" + country + "','" + start + "'," + '0' + ");";

/*
Insert into history
*/
"INSERT INTO History VALUES" + "(" + id + ",'" + 'Ongoing' + "','" + end + "'," + goal + ",'" + dateTime + "');"

/*
INSERT INTO Media
*/
"INSERT INTO Media VALUES" + "(" + id + ",'video','main','" + video + "');" + sql_media + "(" + id + ",'image','about','" + image + "');";

/*
Insert into shipping
*/            
"INSERT INTO Shipping_info VALUES(" + id + ",'" + shipping[i] + "');"

---------------------------------------------------------------------------------------------------------------------------------

/* SIGN UP
--> insertions are done by procedure calls
*/

/*
Insert for creator
*/
"CALL create_new_creator" + "('" + user + "','" + name + "','" + email + "','" + country + "','" + pass + "','" + organization + "')";

/*
Insert for funder
*/
"CALL create_new_funder" + "('" + user + "','" + name + "','" + email + "','" + country + "','" + pass + "'," + " ARRAY["
        for (i = 0; i < preferences.length; i ++) {
            if (i == preferences.length - 1) {
                sql = sql + "'" + preferences[i] + "'";
            } else {
                sql = sql + "'" + preferences[i] + "',";
            }
        }
        sql = sql + "]);"

---------------------------------------------------------------------------------------------------------------------------------
/*Search Query*/

SELECT * FROM (SELECT id, count_occurances($substring, project_description, project_name, user_name) AS rank, project_name FROM projects) AS a WHERE rank > 0 ORDER BY rank DESC, project_name;


---------------------------------------------------------------------------------------------------------------------------------

/*
Complex Query
*/

/*
Select all unreliable creators:
	1. no. of projects where the deadline has been extended more than once
	2. no. of projects where the goal has been decreased
	3. no. of projects with a average rating of less than 2.5
	4. does not have an organization
*/
WITH X AS (SELECT DISTINCT p.id FROM Projects p WHERE EXISTS (SELECT 1 FROM History h WHERE h.project_id = p.id AND (h.end_date,h.time_stamp) > ANY(SELECT h1.end_date,h1.time_stamp FROM History h1 WHERE h1.project_id = p.id))),
Y AS (SELECT DISTINCT p.id FROM Projects p INNER JOIN History h1 ON h1.project_id = p.id INNER JOIN History h2 ON h1.project_id = h2.project_id AND h1.time_stamp > h2.time_stamp AND h1.goal < h2.goal)

SELECT u.name,u.email,u.country_name,u.suspended,a.*,(CASE WHEN c.organization IS NULL THEN 1 ELSE 0 END) AS no_organization FROM (
SELECT c.user_name , 
SUM((SELECT COUNT(*) FROM X WHERE x.id = p.id)) AS num_extended_deadline, 
SUM((SELECT COUNT(*) FROM Y WHERE y.id = p.id)) AS num_goal_decreased, 
SUM((SELECT COUNT(*) FROM (SELECT r.project_id as id FROM Rates r INNER JOIN Projects p ON p.id = r.project_id GROUP BY r.project_id HAVING AVG(r.rating) < 2.5) AS Z WHERE z.id = p.id)) AS low_rating_projects 
FROM Creator c INNER JOIN Projects p ON p.user_name = c.user_name group by c.user_name
) AS a INNER JOIN Creator c ON a.user_name = c.user_name INNER JOIN UserAccount u ON u.user_name = a.user_name WHERE add(num_extended_deadline,num_goal_decreased,low_rating_projects,CASE WHEN c.organization IS NULL THEN 1 ELSE 0 END) > 0 
AND u.suspended = false
ORDER BY num_extended_deadline DESC, num_goal_decreased DESC, low_rating_projects DESC, 9 DESC;


/*
top creators
*/
WITH CurrentPar AS ( SELECT DISTINCT H1.project_id, prj.user_name, H1.end_date, H1.goal, H1.project_status FROM History H1, Projects prj WHERE NOT EXISTS ( SELECT 1 FROM History H2 WHERE H2.project_id = H1.project_id AND H2.time_stamp > H1.time_stamp ) AND prj.id = H1.project_id ),
Stats AS ( SELECT DISTINCT p1.project_id, COALESCE(p1.user_name, r1.user_name, f1.user_name) as user_name, p1.projResult, r1.highRating, f1.num_followers FROM ((SELECT DISTINCT CP.project_id, CP.user_name, CASE WHEN (SUM(P.pledge) >= CP.goal) THEN 1 ELSE 0 END AS projResult FROM Pledges P, CurrentPar CP WHERE P.project_id = CP.project_id AND P.time_stamp <= CP.end_date AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Successful') GROUP BY CP.project_id, CP.user_name, CP.goal) AS p1 FULL OUTER JOIN (SELECT DISTINCT CP.project_id, CP.user_name, CASE WHEN (AVG(R.rating) >= 4.0) THEN 1 ELSE 0 END AS highRating From Rates R, CurrentPar CP WHERE R.project_id = CP.project_id AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Successful') GROUP BY CP.project_id, CP.user_name) AS r1  ON p1.project_id = r1.project_id) FULL OUTER JOIN  (SELECT DISTINCT CP.project_id, CP.user_name, COUNT(F.funder) AS num_followers FROM Follows F, CurrentPar CP WHERE F.projects_followed = CP.project_id AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Successful') GROUP BY CP.project_id, CP.user_name) as f1 ON p1.project_id = f1.project_id ) 
SELECT S.user_name, U.name, U.email, U.country_name, COALESCE(SUM(projresult), 0) as num_successful_proj, COALESCE((SUM(Cast(highRating as Float))/COUNT(Cast(highRating as Float))), 0) as percent_above_4, COALESCE(SUM(num_followers),0) as total_followers FROM Stats S, UserAccount U WHERE S.user_name = U.user_name GROUP BY S.user_name, U.name, U.email, U.country_name ORDER BY num_successful_proj DESC, percent_above_4 DESC, total_followers DESC, user_name DESC LIMIT(10);


/*
Top organization
*/

with orgsCountry as ( select c.organization, SI.country_name from creator c INNER JOIN Tags t ON (c.user_name = t.user_name) INNER JOIN Projects p ON (t.project_id = p.id) inner join shipping_info SI on (p.id = SI.project_id) where c.organization is not null group by c.organization, SI.country_name ) 
SELECT c.organization FROM Creator c INNER JOIN Tags ON (c.user_name = Tags.user_name) INNER JOIN Projects ON (Tags.project_id = Projects.id) INNER JOIN History ON (Projects.id = History.project_id) WHERE History.project_status = 'Successful' and c.Organization is not null GROUP BY c.Organization HAVING COUNT(*) >= 5 
except select c.organization from creator c WHERE c.organization is not null group by c.organization having count(*) < 15 
except select o.organization from orgsCountry o group by o.organization having count(*) < 5 ;





