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
DROP TABLE IF EXISTS Creates CASCADE;
DROP TABLE IF EXISTS Follows CASCADE;
DROP TABLE IF EXISTS Rates CASCADE;
DROP TABLE IF EXISTS Tags CASCADE;
DROP TABLE IF EXISTS Currency CASCADE;
DROP TABLE IF EXISTS CurrencyPair CASCADE;

DROP TRIGGER IF EXISTS currency_trig CASCADE;
DROP FUNCTION IF EXISTS currency_check CASCADE;

CREATE TABLE Country(
	country_name varchar(100) PRIMARY KEY,
	currency_name varchar(10)
);

CREATE TABLE UserAccount (
  user_name     varchar(100) PRIMARY KEY,
  name      varchar(50) NOT NULL,
  email		varchar(100) NOT NULL UNIQUE,
  country_name	varchar(100) REFERENCES Country,
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
	estimated_shipping_date timestamp NOT NULL,
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
	RAISE NOTICE 'Currency not supported'; 
	RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;

/*
If the project does not have any shipping infomation, trivially return true
If the project does not ship to the country the funder resides in, return false
Else return true
*/
CREATE OR REPLACE FUNCTION shipping_check()
RETURNS TRIGGER AS $$
DECLARE ships_to NUMERIC;
BEGIN
SELECT CASE WHEN ((SELECT COUNT(*) FROM Shipping_info WHERE project_id = NEW.project_id) = 0) THEN 1 
		ELSE COUNT(*)
		END INTO ships_to FROM (SELECT c.country_name FROM Country c INNER JOIN UserAccount u ON u.country_name = c.country_name INNER JOIN Funder f ON f.user_name = u.user_name WHERE f.user_name = NEW.user_name) AS c1, (SELECT country_name FROM Shipping_info WHERE project_id = NEW.project_id) AS c2 WHERE c1.country_name = c2.country_name;
IF ships_to = 1 THEN
	RETURN NEW;
ELSE
	RAISE NOTICE 'Project does not ship to country';
	RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION funder_check()
RETURNS TRIGGER AS $$
DECLARE is_Creator boolean;
BEGIN
IF (SELECT COUNT(*) FROM 
	Projects prj WHERE new.project_id = prj.id AND NEW.user_name = prj.user_name) >= 1
	THEN is_Creator = true;
ELSE is_Creator = false;
END IF;

IF is_Creator = true THEN
	RAISE NOTICE 'Creator cannot pledge to their own project';
	RETURN NULL;
ELSE
	RETURN NEW;
END IF;	
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION date_check()
RETURNS TRIGGER AS $$
DECLARE is_after boolean;
BEGIN SELECT true INTO is_after FROM History h WHERE h.project_id = NEW.project_id AND NEW.time_stamp > h.end_date AND h.time_stamp = (SELECT MAX(h1.time_stamp) FROM History h1 WHERE h1.project_id = h.project_id);
IF is_after = true THEN
	RAISE NOTICE 'Pledge is after the project''s end date';
	RETURN NULL;
ELSE RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION admin_check()
RETURNS TRIGGER AS $$
DECLARE is_admin boolean;
BEGIN SELECT true INTO is_admin FROM Admin a WHERE a.user_name = NEW.user_name AND NEW.suspended = true;
IF is_admin = true THEN
	RAISE NOTICE 'Not allowed to suspend admin account';
	RETURN NULL;
ELSE RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER currency_trig
BEFORE INSERT OR UPDATE ON CurrencyPair
FOR EACH ROW EXECUTE PROCEDURE currency_check();

CREATE TRIGGER pledge_insert
BEFORE INSERT ON Pledges
FOR EACH ROW EXECUTE PROCEDURE shipping_check();

CREATE TRIGGER pledge_funder_check
BEFORE INSERT ON Pledges
FOR EACH ROW EXECUTE PROCEDURE funder_check();

CREATE TRIGGER pledge_date_check
BEFORE INSERT OR UPDATE ON Pledges
FOR EACH ROW EXECUTE PROCEDURE date_check();

CREATE TRIGGER suspend_trig
BEFORE UPDATE ON UserAccount
FOR EACH ROW EXECUTE PROCEDURE admin_check();


