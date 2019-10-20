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

CREATE TABLE Projects(
	id int PRIMARY KEY,
	user_name varchar(100) REFERENCES Creator,
	project_name text NOT NULL,
	project_description  text NOT NULL,
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
	link varchar(100) NOT NULL,
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
SELECT COUNT(*) INTO is_supported FROM Country c1, Country c2 WHERE NEW.base_currency = c1.currency_name AND NEW.quote_currency = c2.currency_name;
IF is_supported = 1 THEN
	RETURN NEW;
ELSE
	RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER currency_trig
BEFORE INSERT OR UPDATE ON CurrencyPair
FOR EACH ROW EXECUTE PROCEDURE currency_check();



