DROP TABLE IF EXISTS Country CASCADE;
DROP TABLE IF EXISTS UserAccount CASCADE;
DROP TABLE IF EXISTS Creator CASCADE;
DROP TABLE IF EXISTS Funder CASCADE;
DROP TABLE IF EXISTS Projects CASCADE;
DROP TABLE IF EXISTS History CASCADE;
DROP TABLE IF EXISTS Comments CASCADE;
DROP TABLE IF EXISTS Media CASCADE;
DROP TABLE IF EXISTS Shipping_info CASCADE;
DROP TABLE IF EXISTS Pledges CASCADE;
DROP TABLE IF EXISTS Follows CASCADE;
DROP TABLE IF EXISTS Rates CASCADE;
DROP TABLE IF EXISTS Tags CASCADE;
DROP TABLE IF EXISTS Currency CASCADE;
DROP TABLE IF EXISTS CurrencyPair CASCADE;

DROP TRIGGER IF EXISTS currency_trig ON CurrencyPair;
DROP TRIGGER IF EXISTS check_valid_pledge ON Pledges;
DROP TRIGGER IF EXISTS suspend_trig ON Pledges;
DROP TRIGGER IF EXISTS valid_pledge ON Pledges;
DROP TRIGGER IF EXISTS check_creator_rates ON Rates;
DROP TRIGGER IF EXISTS check_creator_follows ON Follows;
DROP TRIGGER IF EXISTS "Non-trivial constraint 1" ON shipping_info;


DROP FUNCTION IF EXISTS currency_check();
DROP FUNCTION IF EXISTS admin_check();
DROP FUNCTION IF EXISTS count_occurances(text,text,text,varchar(50));
DROP FUNCTION IF EXISTS add(numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS check_valid_pledge();
DROP FUNCTION IF EXISTS get_projects_info(varchar(100));
DROP FUNCTION IF EXISTS get_projects_info_by_type(varchar(100),varchar(50));
DROP FUNCTION IF EXISTS get_projects_info_by_tags(varchar(100),varchar(50));
DROP FUNCTION IF EXISTS check_follows_creator();
DROP FUNCTION IF EXISTS check_rates_creator();
DROP FUNCTION IF EXISTS shippingDestRemoval_check();

DROP PROCEDURE IF EXISTS cancel_project(int);
DROP PROCEDURE IF EXISTS create_new_creator(text,text,text,text,text,text);
DROP PROCEDURE IF EXISTS create_new_funder(varchar(100),varchar(50),varchar(100),varchar(100),varchar(50),varchar(100) ARRAY);

CREATE TABLE Country(
	country_name varchar(100) PRIMARY KEY,
	currency_name varchar(10)
);

CREATE TABLE UserAccount (
  user_name     varchar(100) PRIMARY KEY,
  name      varchar(50) NOT NULL,
  email		varchar(100) NOT NULL UNIQUE,
  country_name	varchar(100) NOT NULL REFERENCES Country,
  password		varchar(50) NOT NULL,
  suspended		boolean NOT NULL,
  date_created	timestamp,
  last_login	timestamp,
  CHECK (email LIKE '%_@__%.__%' AND email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

CREATE TABLE Creator (
	user_name varchar(100) PRIMARY KEY REFERENCES UserAccount (user_name) ON DELETE CASCADE,
	organization varchar(100)
);

CREATE TABLE Funder (
	user_name varchar(100) PRIMARY KEY REFERENCES UserAccount (user_name) ON DELETE CASCADE,
	preferences varchar(50) ARRAY
);

CREATE TABLE Admin (
	user_name varchar(100) PRIMARY KEY REFERENCES UserAccount (user_name) ON DELETE CASCADE
);

CREATE TABLE Projects(
	id int PRIMARY KEY,
	user_name varchar(100) REFERENCES Creator,
	project_name text NOT NULL,
	project_type  varchar(50) NOT NULL,
	project_description text NOT NULL,
	project_location varchar(100) NOT NULL REFERENCES Country (country_name),
	start_date timestamp NOT NULL,
	num_of_views int
);

/*
we need to be careful when inserting the first row of parameters for the project
*/
CREATE TABLE History(
	project_id int REFERENCES Projects (id) ON DELETE CASCADE,
	project_status varchar(100) NOT NULL,
	end_date timestamp NOT NULL,
	goal numeric NOT NULL,
	time_stamp timestamp NOT NULL,
	CHECK(end_date > time_stamp),
	PRIMARY KEY (project_id, time_stamp)
);

/*
TODO: decide a proper primary key -> if a user is deleted but project is not
the row will not be removed.
*/
CREATE TABLE Comments(
	project_id int REFERENCES Projects (id) ON DELETE CASCADE,
	user_name varchar(100) REFERENCES UserAccount (user_name) ON DELETE CASCADE,
	comment text NOT NULL,
	time_stamp timestamp NOT NULL,
	PRIMARY KEY (project_id, user_name, time_stamp)
);

/*
is this also an weak entity set?
*/
CREATE TABLE Media(
	project_id int REFERENCES Projects (id) ON DELETE CASCADE,
	media_type varchar(100) NOT NULL,
	description text NOT NULL,
	link text NOT NULL,
	PRIMARY KEY (project_id, link)
);

CREATE TABLE Shipping_info(
	project_id int REFERENCES Projects (id) ON DELETE CASCADE,
	country_name varchar(100) REFERENCES Country (country_name),
	PRIMARY KEY (project_id, country_name)
);

/*
Constriant: userAccount only can pledge on a particular project once

TODO: add triggers to check funders are not creators of the project
add triggers to ensure that the funder not from a country which the 
projects ship to can add a pledge
*/
CREATE TABLE Pledges(
	project_id int REFERENCES Projects (id),
	user_name varchar(100) REFERENCES Funder (user_name),
	pledge numeric NOT NULL,
	time_stamp timestamp NOT NULL,
	PRIMARY KEY (project_id, user_name)
);

CREATE TABLE Follows(
	projects_followed int REFERENCES Projects (id), 
	funder varchar(100) REFERENCES Funder (user_name),
	PRIMARY KEY (projects_followed, funder)
);

CREATE TABLE Rates(
	user_name varchar(100) REFERENCES Funder (user_name),
	project_id int REFERENCES Projects (id),
	rating int NOT NULL,
	PRIMARY KEY (user_name, project_id)
);

CREATE TABLE Tags(
	user_name varchar(100) REFERENCES Creator (user_name),
	project_id int REFERENCES Projects (id),
	tag_name varchar(50) NOT NULL,
	PRIMARY KEY (user_name,project_id, tag_name)
);


CREATE TABLE CurrencyPair(
	base_currency varchar(10) NOT NULL,
	quote_currency varchar(10) NOT NULL,
	exchange_rate numeric NOT NULL,
	PRIMARY KEY (base_currency, quote_currency)
);

CREATE OR REPLACE FUNCTION currency_check()
RETURNS TRIGGER AS $$ 
DECLARE is_supported NUMERIC;
BEGIN
SELECT COUNT(*) INTO is_supported FROM Country c1, Country c2 WHERE c1.currency_name = NEW.base_currency AND c2.currency_name = NEW.quote_currency;
IF is_supported >= 1 THEN
	RETURN NEW;
ELSE
	RAISE EXCEPTION 'Currency not supported'; 
	RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION admin_check()
RETURNS TRIGGER AS $$
DECLARE is_admin boolean;
BEGIN SELECT true INTO is_admin FROM Admin a WHERE a.user_name = NEW.user_name AND NEW.suspended = true;
IF is_admin = true THEN
	RAISE EXCEPTION 'Not allowed to suspend admin account';
	RETURN NULL;
ELSE RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_occurances(substr text,description text,project_name text, name1 varchar(50)) 
RETURNS numeric AS
$$ DECLARE des text; title text; name varchar(50); sub text;
BEGIN 
sub := LOWER(substr); des := LOWER(description); title := LOWER(project_name); name := LOWER(name1);
RETURN (LENGTH(des) - LENGTH(REPLACE(des,sub,'')) + LENGTH(title) - LENGTH(REPLACE(title,sub,'')) + LENGTH(name) - LENGTH(REPLACE(name,sub,'')))/LENGTH(sub);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add(a numeric,b numeric,c numeric,d numeric)
RETURNS numeric AS
$$
BEGIN
RETURN a+b+c+d;
END$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_valid_pledge()
RETURNS TRIGGER AS $$
DECLARE 
	ships_to INTEGER; is_Creator INTEGER; is_after BOOLEAN;
BEGIN 
	SELECT CASE WHEN 
		((SELECT COUNT(*) FROM Shipping_info WHERE project_id = NEW.project_id) = 0) THEN 1 
			ELSE COUNT(*)
			END INTO ships_to FROM (
				SELECT c.country_name FROM Country c 
				INNER JOIN UserAccount u ON u.country_name = c.country_name 
				INNER JOIN Funder f ON f.user_name = u.user_name WHERE f.user_name = NEW.user_name) AS c1, 
				(SELECT country_name FROM Shipping_info WHERE project_id = NEW.project_id) AS c2 WHERE c1.country_name = c2.country_name;
	SELECT COUNT(*) INTO is_Creator FROM Projects prj WHERE NEW.project_id = prj.id AND NEW.user_name = prj.user_Name;
	SELECT true INTO is_after FROM History h 
		WHERE h.project_id = NEW.project_id 
			AND (NEW.time_stamp > h.end_date OR h.project_status <> 'Ongoing')
			AND h.time_stamp = (SELECT MAX(h1.time_stamp) FROM History h1 WHERE h1.project_id = h.project_id);
	IF ships_to <> 1 THEN
		RAISE EXCEPTION 'Invalid pledge as project does not ship to the user location';
		RETURN NULL;
	ELSEIF is_Creator = 1 THEN
		RAISE EXCEPTION 'Invalid pledge as project creator cannot pledge to their own project';
		RETURN NULL;
	ELSEIF is_after = true THEN
		RAISE EXCEPTION 'Invalid pledge as pledge is made after deadline or project is not Ongoing';
		RETURN NULL;
	END IF;
	RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_follows_creator()
RETURNS TRIGGER AS
$$ DECLARE is_creator boolean;
BEGIN SELECT true INTO is_creator FROM Projects p WHERE p.user_name = NEW.funder AND p.id = NEW.projects_followed;
IF is_creator THEN
	RAISE EXCEPTION 'Creator cannot perform action';
	RETURN NULL;
ELSE RETURN NEW;
END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_rates_creator()
RETURNS TRIGGER AS
$$ DECLARE is_creator boolean;
BEGIN SELECT true INTO is_creator FROM Projects p WHERE p.user_name = NEW.user_name AND p.id = NEW.project_id;
IF is_creator THEN
	RAISE EXCEPTION 'Creator cannot perform action';
	RETURN NULL;
ELSE RETURN NEW;
END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_valid_cancel_pledge()
RETURNS TRIGGER AS 
$$ DECLARE is_valid boolean;
BEGIN SELECT true INTO is_valid FROM Projects p INNER JOIN History h ON h.project_id = p.id WHERE h.project_status = 'Ongoing' AND OLD.project_id = h.project_id AND (h.project_id,h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id);
IF is_valid THEN
	RETURN OLD;
ELSE RAISE EXCEPTION 'Cannot cancel pledge as project is closed';
END IF;
END; $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_projects_info(country_name_in varchar(100))
RETURNS TABLE(
	id int,
	user_name varchar(100),
	project_name text,
	description text,
	link text,
	project_status varchar(100),
	end_date timestamp,
	ships_to_country boolean
)
AS $$
BEGIN 
RETURN QUERY
WITH X AS 
(SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,true FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) ORDER BY project_name),
Y AS (
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id)
EXCEPT
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) ORDER BY project_name
)
SELECT * FROM X UNION ALL SELECT * FROM Y;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_projects_info_by_type(country_name_in varchar(100), type_in varchar(50))
RETURNS TABLE(
	id int,
	user_name varchar(100),
	project_name text,
	description text,
	link text,
	project_status varchar(100),
	end_date timestamp,
	ships_to_country boolean
)
AS $$
BEGIN 
RETURN QUERY
WITH X AS 
(SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,true FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND p.project_type = type_in AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) ORDER BY project_name) ,
Y AS (
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND p.project_type = type_in AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id)
EXCEPT
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id WHERE m.description = 'about' AND p.project_type = type_in AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) ORDER BY project_name
)
SELECT * FROM X UNION ALL SELECT * FROM Y;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_projects_info_by_tags(country_name_in varchar(100), tag varchar(50))
RETURNS TABLE(
	id int,
	user_name varchar(100),
	project_name text,
	description text,
	link text,
	project_status varchar(100),
	end_date timestamp,
	ships_to_country boolean
)
AS $$
BEGIN 
RETURN QUERY
WITH X AS 
(SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,true FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id INNER JOIN Tags t ON t.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) AND t.tag_name = tag ORDER BY project_name),
Y AS (
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id INNER JOIN Tags t ON t.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND t.tag_name = tag
EXCEPT
SELECT p.id, p.user_name, p.project_name, p.project_description, m.link, h.project_status, h.end_date,false FROM Projects p INNER JOIN Media m ON m.project_id = p.id INNER JOIN History h ON h.project_id = p.id INNER JOIN Tags t ON t.project_id = p.id WHERE m.description = 'about' AND (h.project_id, h.time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id) AND (country_name_in IN (SELECT s.country_name FROM Shipping_info s WHERE s.project_id = p.id) OR (SELECT COUNT(*) = 0 FROM Shipping_info s WHERE s.project_id = p.id)) AND t.tag_name = tag ORDER BY project_name
)
SELECT * FROM X UNION ALL SELECT * FROM Y;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "shippingDestRemoval_check"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE count NUMERIC;
	begin --The Creator cannot remove a shipping destination if there are funders which pledged to the project from that country
		--First, find out if there are funders which pledged to the project from that country
		select count(*) into count from shipping_info si
		inner join projects project on (project.id = si.project_id)
		inner join pledges pledges on (si.project_id = pledges.project_id)
		inner join funder funder on (pledges.user_name = funder.user_name)
		inner join useraccount useraccount on (funder.user_name = useraccount.user_name)
		where (useraccount.country_name = old.country_name) and (project.id = old.project_id);
		if count > 0 then
			raise notice 'Cannot remove shipping destination as there are pledges to the project from that country.';
			return null;
		elsif (TG_OP = 'DELETE') then
			raise notice 'Shipping dest removed';
			return old;
		elsif (TG_OP = 'UPDATE') then
			raise notice 'Shipping dest updated';
			return new;
		end if;
	END;
$function$
;

CREATE OR REPLACE PROCEDURE cancel_project(id int)
AS $$ 
BEGIN WITH X AS (
SELECT end_date, goal, project_id FROM History WHERE project_id = id AND (id,time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id)
), Y AS (SELECT COALESCE(SUM(pledge),0) AS pledge FROM Pledges WHERE project_id = id)
INSERT INTO History VALUES(id,
	CASE WHEN ((SELECT goal FROM X) <= (SELECT pledge FROM Y)) THEN 'Successful' ELSE 'Unsuccessful' END
	,(SELECT end_date FROM X),(SELECT goal FROM X),CURRENT_TIMESTAMP);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_new_creator(user_name text, name text, email text, country_name text, password text, organization text)
AS $$ 
BEGIN 
INSERT INTO UserAccount VALUES(user_name, name, email, country_name, password, 'false', CURRENT_TIMESTAMP);
INSERT INTO Creator VALUES(user_name, organization);
INSERT INTO Funder VALUES(user_name);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_new_funder(user_name varchar(100), name varchar(50), email varchar(100), country_name varchar(100), password varchar(50), preferences varchar(100) ARRAY)
AS $$
BEGIN 
INSERT INTO UserAccount VALUES(user_name, name, email, country_name, password, 'false', CURRENT_TIMESTAMP);
INSERT INTO Funder VALUES(user_name, preferences);
END $$ LANGUAGE plpgsql;

CREATE TRIGGER currency_trig
BEFORE INSERT OR UPDATE ON CurrencyPair
FOR EACH ROW EXECUTE PROCEDURE currency_check();

CREATE TRIGGER suspend_trig
BEFORE UPDATE ON UserAccount
FOR EACH ROW EXECUTE PROCEDURE admin_check();

CREATE TRIGGER valid_pledge
BEFORE INSERT ON Pledges
FOR EACH ROW EXECUTE PROCEDURE check_valid_pledge();

CREATE TRIGGER check_valid_cancel_pledge
BEFORE DELETE ON Pledges
FOR EACH ROW EXECUTE PROCEDURE check_valid_cancel_pledge();

CREATE TRIGGER check_creator_rates
BEFORE INSERT OR UPDATE ON Rates
FOR EACH ROW EXECUTE PROCEDURE check_rates_creator();

CREATE TRIGGER check_creator_follows
BEFORE INSERT OR UPDATE ON Follows
FOR EACH ROW EXECUTE PROCEDURE check_follows_creator();

CREATE TRIGGER "Non-trivial constraint 1" before
delete or update on
public.shipping_info for each row execute procedure "shippingDestRemoval_check"();
