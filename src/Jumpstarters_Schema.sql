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
DROP TABLE IF EXISTS CurrencyPair CASCADE;

DROP TRIGGER IF EXISTS currency_trig;
DROP TRIGGER IF EXISTS valid_pledge;
DROP TRIGGER IF EXISTS suspend_trig;


DROP FUNCTION IF EXISTS currency_check();
DROP FUNCTION IF EXISTS admin_check();
DROP FUNCTION IF EXISTS check_valid_pledge(integer, integer, boolean);
DROP FUNCTION IF EXISTS count_occurances(text,text,text,varchar(50));
DROP FUNCTION IF EXISTS add(numeric,numeric,numeric,numeric);


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
	preferences varchar(100) ARRAY
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

CREATE OR REPLACE PROCEDURE cancel_project(id int)
AS $$ 
BEGIN 
WITH X AS
(SELECT end_date, goal FROM History WHERE project_id = id AND (id,time_stamp) IN (SELECT project_id, MAX(time_stamp) FROM History GROUP BY project_id))
INSERT INTO History VALUES(id,'Cancelled',(SELECT end_date FROM X),(SELECT goal FROM X),CURRENT_TIMESTAMP);
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

CREATE TRIGGER valid_pledge
BEFORE INSERT ON Pledges
FOR EACH ROW EXECUTE PROCEDURE check_valid_pledge();
