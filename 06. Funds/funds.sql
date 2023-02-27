SELECT COUNT(status)
FROM company
WHERE status = 'closed'

----------------------------

SELECT SUM(funding_total)
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
GROUP BY name
ORDER BY SUM(funding_total) DESC

-----------------------------

SELECT SUM(price_amount)
FROM acquisition 
WHERE term_code = 'cash'
      AND CAST(acquired_at AS date) BETWEEN '2011-01-01' AND '2013-12-31'

-----------------------------

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%'

-----------------------------

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' 
      AND last_name LIKE 'K%'

-----------------------------

SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code 
ORDER BY SUM(funding_total) DESC

-----------------------------

SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round 
GROUP BY funded_at
HAVING MIN(raised_amount) <> 0
       AND MIN(raised_amount) <> MAX(raised_amount)

-----------------------------

SELECT *,
    CASE
        WHEN invested_companies >= 100 THEN 'high_activity'
        WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
        WHEN invested_companies < 20 THEN 'low_activity'
    END
FROM fund

-----------------------------

SELECT ROUND(AVG(investment_rounds)),
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund
GROUP BY CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END
ORDER BY ROUND(AVG(investment_rounds));

-----------------------------

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) <> 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10

-----------------------------

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id

-----------------------------

SELECT c.name,
       COUNT(DISTINCT e.instituition)
FROM company AS c
JOIN people AS p ON c.id=p.company_id
JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5;

-----------------------------

SELECT name
FROM company 
WHERE id in (SELECT company_id
             FROM funding_round
             WHERE is_first_round = 1 AND is_last_round = 1)
AND status = 'closed';

-----------------------------

SELECT id
FROM people
WHERE company_id IN (SELECT id
                     FROM company 
                     WHERE id in (SELECT company_id
                                  FROM funding_round
                                  WHERE is_first_round = 1 AND is_last_round = 1)
                     AND status = 'closed');

-----------------------------

SELECT DISTINCT p.id,
       e.instituition
FROM people AS p
JOIN education AS e ON p.id=e.person_id
WHERE p.company_id IN (SELECT id
                     FROM company 
                     WHERE id in (SELECT company_id
                                  FROM funding_round
                                  WHERE is_first_round = 1 AND is_last_round = 1)
                     AND status = 'closed');

-----------------------------

SELECT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN education AS e ON p.id=e.person_id
WHERE p.company_id IN (SELECT id
                     FROM company 
                     WHERE id in (SELECT company_id
                                  FROM funding_round
                                  WHERE is_first_round = 1 AND is_last_round = 1)
                     AND status = 'closed')
GROUP BY p.id;

-----------------------------

SELECT AVG(count_inst)
FROM
(SELECT p.id,
        COUNT(e.instituition) AS count_inst
FROM people AS p
JOIN education AS e ON p.id=e.person_id
WHERE p.company_id IN (SELECT id
                     FROM company 
                     WHERE id in (SELECT company_id
                                  FROM funding_round
                                  WHERE is_first_round = 1 AND is_last_round = 1)
                     AND status = 'closed')
GROUP BY p.id) AS pp;

-----------------------------

SELECT AVG(inst)
FROM (SELECT COUNT(e.instituition) AS inst
FROM people AS p
JOIN education AS e ON p.id=e.person_id
WHERE p.company_id IN (SELECT c.id
                       FROM company AS c
                       WHERE c.name ='Facebook')
GROUP BY p.id) AS cc

-----------------------------

SELECT f.name AS name_of_fund,
       c.name as name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
JOIN company AS c ON c.id=i.company_id
JOIN fund AS f ON i.fund_id=f.id
JOIN (SELECT *
               FROM funding_round
               WHERE funded_at BETWEEN '2012-01-01' AND '2013-12-31') AS fr ON i.funding_round_id=fr.id
WHERE c.milestones > 6

-----------------------------

SELECT c_buyer.name,
       a.price_amount,
       c_seller.name AS selname,
       c_seller.funding_total,
       ROUND(a.price_amount/c_seller.funding_total) AS ratio
FROM acquisition AS a
LEFT JOIN company AS c_buyer ON a.acquiring_company_id=c_buyer.id
LEFT JOIN company AS c_seller ON a.acquired_company_id=c_seller.id
WHERE a.price_amount <> 0 AND c_seller.funding_total <> 0
ORDER BY a.price_amount DESC, 
         selname 
LIMIT 10;

-----------------------------

SELECT c.name,
       EXTRACT (MONTH FROM fr.funded_at)
FROM company AS c
JOIN (SELECT *
FROM funding_round
WHERE EXTRACT (YEAR FROM funded_at) BETWEEN '2010' AND '2013'
      AND raised_amount <> 0) AS fr ON c.id=fr.company_id
WHERE c.category_code = 'social'

-----------------------------

SELECT f1.MONTH,
       f1.count_of_fund,
       f2.count_of_acquired,
       f2.sum_of_acquired
FROM (SELECT EXTRACT(MONTH
                  FROM fr.funded_at) AS MONTH,
          COUNT(DISTINCT f.name) AS count_of_fund
   FROM funding_round AS fr
   LEFT JOIN investment AS i ON i.funding_round_id = fr.id
   LEFT JOIN fund AS f ON i.fund_id = f.id
   WHERE EXTRACT(YEAR
                 FROM fr.funded_at) BETWEEN 2010 AND 2013
     AND f.country_code = 'USA'
   GROUP BY MONTH) AS f1
JOIN (SELECT EXTRACT(MONTH
                  FROM acquired_at) AS MONTH,
          COUNT(acquired_company_id) AS count_of_acquired,
          SUM(price_amount) AS sum_of_acquired
   FROM acquisition
   WHERE EXTRACT(YEAR
                 FROM acquired_at) BETWEEN 2010 AND 2013
   GROUP BY MONTH) AS f2 ON f1.MONTH=f2.MONTH

-----------------------------

WITH
c1 AS (SELECT country_code,
       AVG(funding_total) AS avg_2011
FROM company
WHERE EXTRACT (YEAR FROM founded_at) = '2011'
GROUP BY country_code),

c2 AS (SELECT country_code,
       AVG(funding_total) AS avg_2012
FROM company
WHERE EXTRACT (YEAR FROM founded_at) = '2012'
GROUP BY country_code),

c3 AS (SELECT country_code,
       AVG(funding_total) AS avg_2013
FROM company
WHERE EXTRACT (YEAR FROM founded_at) = '2013'
GROUP BY country_code)

SELECT c1.country_code,
       c1.avg_2011,
       c2.avg_2012,
       c3.avg_2013
FROM c1
JOIN c2 ON c1.country_code=c2.country_code
JOIN c3 ON c1.country_code=c3.country_code
ORDER BY c1.avg_2011 DESC