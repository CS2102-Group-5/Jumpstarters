DROP TABLE IF EXISTS Country CASCADE;
DROP TABLE IF EXISTS UserAccount CASCADE;
DROP TABLE IF EXISTS Creator CASCADE;
DROP TABLE IF EXISTS Funder CASCADE;
DROP TABLE IF EXISTS Projects CASCADE;
DROP TABLE IF EXISTS Parameters CASCADE;
DROP TABLE IF EXISTS Comments CASCADE;
DROP TABLE IF EXISTS Media CASCADE;
DROP TABLE IF EXISTS Shipping_info CASCADE;
DROP TABLE IF EXISTS Pledges CASCADE;
DROP TABLE IF EXISTS Creates CASCADE;
DROP TABLE IF EXISTS Follows CASCADE;
DROP TABLE IF EXISTS Rates CASCADE;

CREATE TABLE Country(
	country_name varchar(100) PRIMARY KEY
);

CREATE TABLE UserAccount (
  user_name     varchar(100) PRIMARY KEY,
  name      varchar(50) NOT NULL,
  email		varchar(100) NOT NULL UNIQUE,
  country_name	varchar(100) REFERENCES Country,
  date_created	timestamp,
  last_login	timestamp,
  password		varchar(50)
);

CREATE TABLE Creator (
	user_name varchar(100) PRIMARY KEY REFERENCES UserAccount (user_name) ON DELETE CASCADE
);

CREATE TABLE Funder (
	user_name varchar(100) PRIMARY KEY REFERENCES UserAccount (user_name) ON DELETE CASCADE
);

CREATE TABLE Projects(
	id int PRIMARY KEY,
	project_name text NOT NULL,
	project_description  text NOT NULL,
	project_location varchar(100) NOT NULL REFERENCES Country (country_name),
	start_date timestamp NOT NULL,
	num_of_views int
);

/*
we need to be careful when inserting the first row of parameters for the project
*/
CREATE TABLE Parameters(
	project_id int REFERENCES Projects (id) ON DELETE CASCADE,
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

CREATE TABLE Creates(
	creator_name varchar(100) REFERENCES Creator (user_name),
	project_id int REFERENCES Projects (id),
	PRIMARY KEY (creator_name, project_id)
);


CREATE TABLE Follows(
	projects_followed int REFERENCES Projects (id), 
	funder varchar(100) REFERENCES Funder (user_name),
	PRIMARY KEY (projects_followed, funder)
);

CREATE TABLE Rates(
	user_name varchar(100) REFERENCES Funder,
	project_id int REFERENCES Projects (id),
	rating int NOT NULL,
	PRIMARY KEY (user_name, project_id)
);



