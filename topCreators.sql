/**The list of the top 10 Creators in the Jumpstarter system based on the following criteria in order of priority. In the case of a tie, the next criteria is used to rank the creators. (Kathleen)
 * 1. No. of Successful projects
 * 	  Determined by whether the project has reached its goal by the end-date
 * 2. % of Projects of the Creator with a more than 4.0 rating
 * 3. Total No. of followers of all projects
 * If there are any remaining ties, they are ordered according to alphabetical order
 */

-- Dummy Data for Testing
INSERT INTO Country VALUES ('Germany', 'EUR');
INSERT INTO Country VALUES ('Singapore','SGD');
INSERT INTO Country VALUES ('United States of America','USD');
INSERT INTO Country VALUES ('Japan','JPY');
INSERT INTO Country VALUES ('France','EUR');
INSERT INTO Country VALUES ('Netherlands','EUR');
INSERT INTO Country VALUES ('United Kingdom','GBP');

INSERT INTO UserAccount VALUES ('FounderFather', 'GeorgeWashington', 'georgeWashington@gmail.com', 'United States of America','cdahsi', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('MarieAntoinette', 'MarieAntoinette', 'marieAntoinette@gmail.com', 'France', 'aswvevb', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('SirStamfordRaffles', 'StamfordRaffles', 'raffles@gmail.com', 'Singapore', 'daoiend', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('ONobunaga', 'Oda Nobunaga', 'odaNobunaga@gmail.com', 'Japan', 'boendoa' ,'2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('Scientist', 'Albert Einstein', 'albertEinstein@gmail.com', 'Germany', 'mspxieg', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('SirWinstonChurchhill', 'Winston Churchhill', 'winstonChurchhill@gmail.com', 'United Kingdom', 'peidna', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('JohnDoe', 'John Doe', 'johndoe@gmail.com', 'United States of America', 'qpandugv', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('MaryJane', 'Mary Jane', 'maryJane@gmail.com', 'United States of America', 'cveug', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('MJ', 'Mary Jane', 'mj@gmail.com', 'United Kingdom', 'bopeodns', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('HenryToh', 'Henry Toh', 'henryToh@gmail.com', 'Singapore', 'flayeb', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('MarissaYeo', 'Marissa Yeo', 'marissaYeo@gmail.com', 'Singapore', 'qrxbai', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('HubertDubos', 'Hubert Dubos', 'HubertDubos@gmail.com', 'France', 'aldige', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('JacobLeBeau', 'Jacob LeBeau', 'JacobLeBeau@gmail.com', 'France', 'apcneidb', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('IvonnePreiss', 'Ivonne Preiss', 'IvonnePreiss@gmail.com', 'Germany', 'ciehun', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('HirakawaDaichi', 'Hirakawa Daichi', 'HirakawaDaichi@gmail.com', 'Japan', 'kzbuei', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);
INSERT INTO UserAccount VALUES ('KuroseMayu', 'Kurose Mayu', 'KuroseMayu@gmail.com', 'Japan', 'spdbuts', '2019-01-01 00:00:01',CURRENT_TIMESTAMP);

INSERT INTO Creator VALUES ('FounderFather', 'FutureLeaders');
INSERT INTO Creator VALUES ('MarieAntoinette', 'Royalty');
INSERT INTO Creator VALUES ('SirStamfordRaffles', 'ExploringTheUnknown');
INSERT INTO Creator VALUES ('ONobunaga', 'Fireworks');
INSERT INTO Creator VALUES ('Scientist', 'Academia');
INSERT INTO Creator VALUES ('SirWinstonChurchhill', 'Writers Guild');

INSERT INTO Funder VALUES ('JohnDoe', ARRAY['Comics & Illustration']);
INSERT INTO Funder VALUES ('MaryJane', ARRAY['Film', 'Comics & Illustration']);
INSERT INTO Funder VALUES ('MJ', ARRAY['Design & Tech']);
INSERT INTO Funder VALUES ('HenryToh', ARRAY['Games']);
INSERT INTO Funder VALUES ('MarissaYeo', ARRAY['Food & Craft', 'Film']);
INSERT INTO Funder VALUES ('MarieAntoinette', ARRAY['Arts', 'Music']);
INSERT INTO Funder VALUES ('SirStamfordRaffles', ARRAY['Design & Tech']);
INSERT INTO Funder VALUES ('HubertDubos', ARRAY['Food & Craft']);
INSERT INTO Funder VALUES ('JacobLeBeau', ARRAY['Publishing']);
INSERT INTO Funder VALUES ('IvonnePreiss', ARRAY['Publishing']);
INSERT INTO Funder VALUES ('HirakawaDaichi', ARRAY['Design & Tech']);
INSERT INTO Funder VALUES ('KuroseMayu', ARRAY['Music', 'Film']);
INSERT INTO Funder VALUES ('FounderFather', ARRAY['Music', 'Publishing']);
INSERT INTO Funder VALUES ('ONobunaga', ARRAY['Food & Craft', 'Design & Tech']);
INSERT INTO Funder VALUES ('Scientist', ARRAY['Design & Tech']);
INSERT INTO Funder VALUES ('SirWinstonChurchhill', ARRAY['Publishing']);

INSERT INTO Projects VALUES (0001, 'Scientist', 'Research Project X', 'Design & Tech', 'Germany', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0002, 'SirWinstonChurchhill', 'Video Broadcast', 'Film', 'United Kingdom', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0003, 'SirStamfordRaffles', 'Plant Biology Book', 'Publishing', 'Singapore', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0004, 'Scientist', 'Research Project Y', 'Design & Tech', 'Germany', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0005, 'MarieAntoinette', 'Art Gallery Launch', 'Arts', 'France', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0006, 'ONobunaga', 'New Fireworks Product', 'Food & Craft', 'Japan', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0007, 'Scientist', 'Research Project Z', 'Design & Tech', 'Germany', '2019-01-01 00:00:01', 0);
INSERT INTO Projects VALUES (0008, 'SirWinstonChurchhill', 'New Book', 'Publishing', 'United Kingdom', '2019-01-01 00:00:01', 0);

INSERT INTO History VALUES (0001, 'Ongoing', '2019-05-01 00:00:01', 1000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0002, 'Ongoing', '2019-05-01 00:00:01', 2000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0003, 'Ongoing', '2019-05-01 00:00:01', 3000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0004, 'Ongoing', '2019-05-01 00:00:01', 4000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0005, 'Ongoing', '2019-05-01 00:00:01', 5000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0006, 'Ongoing', '2019-05-01 00:00:01', 6000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0007, 'Ongoing', '2019-05-01 00:00:01', 7000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0008, 'Ongoing', '2019-05-01 00:00:01', 3000, '2019-03-01 00:00:01');
INSERT INTO History VALUES (0008, 'Closed', '2019-05-01 00:00:01', 3000, '2019-03-03 00:00:01');
INSERT INTO History VALUES (0007, 'Ongoing', '2019-05-01 00:00:01', 3000, '2019-03-03 00:00:01');

INSERT INTO Comments VALUES (0001, 'HirakawaDaichi', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0001, 'Scientist', 'yyy', '2019-03-02 00:00:01');
INSERT INTO Comments VALUES (0002, 'JacobLeBeau', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0003, 'KuroseMayu', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0004, 'MarissaYeo', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0005, 'MarissaYeo', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0005, 'MarieAntoinette', 'yyy', '2019-03-02 00:00:01');
INSERT INTO Comments VALUES (0006, 'IvonnePreiss', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0007, 'HenryToh', 'xxx', '2019-03-01 00:00:01');
INSERT INTO Comments VALUES (0001, 'HirakawaDaichi', 'zzz', '2019-03-03 00:00:01');

INSERT INTO Media VALUES (0001, 'ma', 'da', 'linka');
INSERT INTO Media VALUES (0002, 'mb', 'db', 'linkb');
INSERT INTO Media VALUES (0003, 'mc', 'dc', 'linkc');
INSERT INTO Media VALUES (0004, 'ma', 'dd', 'linkd');
INSERT INTO Media VALUES (0005, 'ma', 'de', 'linke');
INSERT INTO Media VALUES (0006, 'mb', 'df', 'linkb');

INSERT INTO Shipping_info VALUES (0001, 'United Kingdom', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0001, 'Japan', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0001, 'Singapore', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0002, 'France', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0002, 'Singapore', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0003, 'France', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0003, 'Germany', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0004, 'United States of America', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0004, 'Japan', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'Singapore', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'Germany', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'United Kingdom', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'Netherlands', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'France', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0005, 'Japan', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0006, 'Germany', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0007, 'Singapore', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0007, 'Japan', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0008, 'Singapore', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0008, 'Japan', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0008, 'Netherlands', CURRENT_TIMESTAMP);
INSERT INTO Shipping_info VALUES (0008, 'United Kingdom', CURRENT_TIMESTAMP);


INSERT INTO Pledges VALUES (0001, 'HirakawaDaichi', 250, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0001, 'MJ', 200, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0001, 'SirStamfordRaffles', 750, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0002, 'MarieAntoinette', 300, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0003, 'JacobLeBeau', 1300, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0003, 'IvonnePreiss', 780, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0003, 'Scientist', 1000, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0004, 'HirakawaDaichi', 250,'2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0005, 'MarissaYeo', 300, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0006, 'IvonnePreiss', 6000, '2019-05-05 00:00:01'); /**Made after deadline**/
INSERT INTO Pledges VALUES (0007, 'HirakawaDaichi', 250, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0008, 'KuroseMayu', 650, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0008, 'HenryToh', 500, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0008, 'MJ', 250, '2019-03-03 00:00:01');
INSERT INTO Pledges VALUES (0008, 'HirakawaDaichi', 400, '2019-03-03 00:00:01');


INSERT INTO Follows VALUES (0001, 'HirakawaDaichi');
INSERT INTO Follows VALUES (0001, 'MJ');
INSERT INTO Follows VALUES (0001, 'SirStamfordRaffles');
INSERT INTO Follows VALUES (0002, 'JacobLeBeau');
INSERT INTO Follows VALUES (0003, 'MarieAntoinette');
INSERT INTO Follows VALUES (0004, 'HirakawaDaichi');
INSERT INTO Follows VALUES (0005, 'MarissaYeo');
INSERT INTO Follows VALUES (0005, 'IvonnePreiss');
INSERT INTO Follows VALUES (0006, 'HenryToh');
INSERT INTO Follows VALUES (0006, 'KuroseMayu');
INSERT INTO Follows VALUES (0006, 'MarissaYeo');
INSERT INTO Follows VALUES (0007, 'HirakawaDaichi');
INSERT INTO Follows VALUES (0007, 'MJ');
INSERT INTO Follows VALUES (0008, 'MJ');
INSERT INTO Follows VALUES (0008, 'HenryToh');
INSERT INTO Follows VALUES (0008, 'KuroseMayu');
INSERT INTO Follows VALUES (0008, 'HirakawaDaichi');

INSERT INTO Rates VALUES ('HirakawaDaichi', 0001, 4);
INSERT INTO Rates VALUES ('HirakawaDaichi', 0004, 5);
INSERT INTO Rates VALUES ('HirakawaDaichi', 0007, 5);
INSERT INTO Rates VALUES ('MJ', 0001, 4);
INSERT INTO Rates VALUES ('SirStamfordRaffles', 0001, 3);
INSERT INTO Rates VALUES ('IvonnePreiss', 0003, 4);
INSERT INTO Rates VALUES ('JacobLeBeau', 0003, 4);
INSERT INTO Rates VALUES ('MarissaYeo', 0005, 5);
INSERT INTO Rates VALUES ('KuroseMayu', 0008, 4);

INSERT INTO Tags VALUES ('Scientist', 0001, 'xxx');
INSERT INTO Tags VALUES ('Scientist', 0001, 'yyy');
INSERT INTO Tags VALUES ('SirStamfordRaffles', 0003, 'zzz');

INSERT INTO CurrencyPair VALUES ('SGD', 'USD', 0.73);
INSERT INTO CurrencyPair VALUES ('SGD', 'EUR', 0.66);
INSERT INTO CurrencyPair VALUES ('SGD', 'JPY', 79.45);
INSERT INTO CurrencyPair VALUES ('SGD', 'GBP', 0.56);
INSERT INTO CurrencyPair VALUES ('USD', 'SGD', 1.36);
INSERT INTO CurrencyPair VALUES ('USD', 'EUR', 0.9);
INSERT INTO CurrencyPair VALUES ('USD', 'JPY', 108.41);
INSERT INTO CurrencyPair VALUES ('USD', 'GBP', 0.77);
INSERT INTO CurrencyPair VALUES ('EUR', 'SGD', 1.52);
INSERT INTO CurrencyPair VALUES ('EUR', 'USD', 1.12);
INSERT INTO CurrencyPair VALUES ('EUR', 'JPY', 121.03);
INSERT INTO CurrencyPair VALUES ('EUR', 'GBP', 0.86);
INSERT INTO CurrencyPair VALUES ('JPY', 'SGD', 0.013);
INSERT INTO CurrencyPair VALUES ('JPY', 'EUR', 0.0083);
INSERT INTO CurrencyPair VALUES ('JPY', 'USD', 0.0092);
INSERT INTO CurrencyPair VALUES ('JPY', 'GBP', 0.0071);
INSERT INTO CurrencyPair VALUES ('GBP', 'SGD', 1.77);
INSERT INTO CurrencyPair VALUES ('GBP', 'EUR', 1.16);
INSERT INTO CurrencyPair VALUES ('GBP', 'JPY', 140.62);
INSERT INTO CurrencyPair VALUES ('GBP', 'USD', 1.30);

-- Dummy Table for Answer
DROP TABLE IF EXISTS topCreators_Test CASCADE;
CREATE TABLE topCreators_Test (
  user_name             varchar(100),
  name                  varchar(50),
  email                 varchar(100),
  country_name          varchar(100),
  num_successful_proj   integer,
  percent_above_4       numeric,
  total_followers       integer
);

-- Dummy Data for Answer
INSERT INTO topCreators_Test VALUES ('SirStamfordRaffles', 'StamfordRaffles', 'raffles@gmail.com', 'Singapore', 1, 1.00, 1);
INSERT INTO topCreators_Test VALUES ('Scientist', 'Albert Einstein', 'albertEinstein@gmail.com', 'Germany', 1, 2/3.0, 6);
INSERT INTO topCreators_Test VALUES ('MarieAntoinette', 'MarieAntoinette', 'marieAntoinette@gmail.com', 'France', 0, 1.00, 2);
INSERT INTO topCreators_Test VALUES ('ONobunaga', 'Oda Nobunaga', 'odaNobunaga@gmail.com', 'Japan', 0, 0.00, 3);
INSERT INTO topCreators_Test VALUES ('SirWinstonChurchhill', 'Winston Churchhill', 'winstonChurchhill@gmail.com', 'United Kingdom', 0, 0.00, 1);

-- TEST YOUR ANSWER HERE
DROP VIEW IF EXISTS topCreators;
CREATE VIEW topCreators (user_name, name, email, country, num_successful_proj, percent_above_4, num_followers) AS					  
	WITH CurrentPar AS (
		SELECT DISTINCT H1.project_id, prj.user_name, H1.end_date, H1.goal, H1.project_status
		FROM History H1, Projects prj
		WHERE NOT EXISTS (
			SELECT 1 FROM History H2
			WHERE H2.project_id = H1.project_id AND H2.time_stamp > H1.time_stamp
		)
		AND prj.id = H1.project_id 
	), 
	Stats AS (
		SELECT DISTINCT p1.project_id, COALESCE(p1.user_name, r1.user_name, f1.user_name) as user_name, p1.projResult, r1.highRating, f1.num_followers
		FROM 
		((SELECT DISTINCT CP.project_id, CP.user_name,
		CASE 
			WHEN (SUM(P.pledge) >= CP.goal) THEN 1
			ELSE 0
		END AS projResult	
		FROM Pledges P, CurrentPar CP
		WHERE P.project_id = CP.project_id AND P.time_stamp <= CP.end_date
			AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Completed')
		GROUP BY CP.project_id, CP.user_name, CP.goal) AS p1

		FULL OUTER JOIN

		(SELECT DISTINCT CP.project_id, CP.user_name,
		CASE
			WHEN (AVG(R.rating) >= 4.0) THEN 1
			ELSE 0
		END AS highRating	
		From Rates R, CurrentPar CP
		WHERE R.project_id = CP.project_id
			AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Completed')
		GROUP BY CP.project_id, CP.user_name) AS r1
		
		ON p1.project_id = r1.project_id)

		FULL OUTER JOIN
		
		(SELECT DISTINCT CP.project_id, CP.user_name, COUNT(F.funder) AS num_followers
		FROM Follows F, CurrentPar CP
		WHERE F.projects_followed = CP.project_id 
			AND (CP.project_status = 'Ongoing' OR CP.project_status = 'Completed')
		GROUP BY CP.project_id, CP.user_name) as f1

		ON p1.project_id = f1.project_id 
	)
	SELECT S.user_name, U.name, U.email, U.country_name,
		COALESCE(SUM(projresult), 0) as num_successful_proj, 
		COALESCE((SUM(Cast(highRating as Float))/COUNT(Cast(highRating as Float))), 0) as percent_above_4,
		COALESCE(SUM(num_followers),0) as total_followers
	FROM Stats S, UserAccount U
	WHERE S.user_name = U.user_name
	GROUP BY S.user_name, U.name, U.email, U.country_name
	ORDER BY num_successful_proj DESC, percent_above_4 DESC, total_followers DESC, user_name DESC;
------------------------

-- Test Code: MAKE SURE YOU HAVE YOUR ANSWER
SELECT * FROM topCreators;
SELECT * FROM topCreators_Test;
