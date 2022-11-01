/***********************************************
** File: Assignment2-PartC.sql
** Desc: Combining Data, Nested Queries, Views and Indexes, Transforming Data 
** Author: Luke Schwenke
** Date: 10/27/2022
************************************************/

############################### QUESTION 1 ############################### 

# a) List the actors (firstName, lastName) who acted in more then 25 movies.
# Note: Also show the count of movies against each actor

SELECT ACT.FIRST_NAME,
	   ACT.LAST_NAME,
       COUNT(DISTINCT(FILM.TITLE)) AS FILM_COUNT
FROM ACTOR AS ACT
LEFT JOIN FILM_ACTOR AS FA ON ACT.ACTOR_ID = FA.ACTOR_ID
LEFT JOIN FILM ON FILM.FILM_ID = FA.FILM_ID
GROUP BY FIRST_NAME, 
		 LAST_NAME
HAVING FILM_COUNT > 25
ORDER BY 3 DESC;

# b) List the actors who have worked in the German language movies.
# Note: Please execute the below SQL before answering this question. 

SET SQL_SAFE_UPDATES=0;
UPDATE film SET language_id=6 WHERE title LIKE "%ACADEMY%";

SELECT DISTINCT ACT.FIRST_NAME,
	            ACT.LAST_NAME
FROM ACTOR AS ACT
LEFT JOIN FILM_ACTOR AS FA ON ACT.ACTOR_ID = FA.ACTOR_ID
LEFT JOIN FILM ON FILM.FILM_ID = FA.FILM_ID
WHERE FILM.LANGUAGE_ID IN (SELECT LANGUAGE_ID 
						   FROM LANGUAGE 
                           WHERE NAME = 'German') ORDER BY 2;

# c) List the actors who acted in horror movies.
# Note: Show the count of movies against each actor in the result set.

SELECT DISTINCT ACT.FIRST_NAME,
	            ACT.LAST_NAME,
                COUNT(*) AS HORROR_COUNT
FROM ACTOR AS ACT
LEFT JOIN FILM_ACTOR AS FA ON ACT.ACTOR_ID = FA.ACTOR_ID
LEFT JOIN FILM_CATEGORY AS CAT ON CAT.FILM_ID = FA.FILM_ID
WHERE CAT.CATEGORY_ID IN (SELECT CATEGORY_ID 
						   FROM CATEGORY
                           WHERE NAME = 'Horror')
GROUP BY ACT.ACTOR_ID # Note: You could also group on ACT.FIRST_NAME, ACT.LAST_NAME but there are 2 Susan Davis
ORDER BY 3 DESC;

# d) List all customers who rented more than 3 horror movies.

SELECT R.CUSTOMER_ID,
	   C.FIRST_NAME,
       C.LAST_NAME,
       COUNT(*) AS COUNT
FROM RENTAL AS R
LEFT JOIN INVENTORY AS I ON I.INVENTORY_ID = R.INVENTORY_ID
LEFT JOIN FILM ON FILM.FILM_ID = I.FILM_ID
LEFT JOIN FILM_CATEGORY FCAT ON FCAT.FILM_ID = FILM.FILM_ID
LEFT JOIN CATEGORY CAT ON CAT.CATEGORY_ID = FCAT.CATEGORY_ID
LEFT JOIN CUSTOMER C ON C.CUSTOMER_ID = R.CUSTOMER_ID
WHERE CAT.NAME = 'Horror'
GROUP BY R.CUSTOMER_ID
HAVING COUNT > 3
ORDER BY 4 DESC;

# e) List all customers who rented the movie which starred SCARLETT BENING

SELECT DISTINCT R.CUSTOMER_ID,
			    C.FIRST_NAME,
			    C.LAST_NAME
FROM RENTAL AS R
LEFT JOIN INVENTORY AS I ON I.INVENTORY_ID = R.INVENTORY_ID
LEFT JOIN FILM ON FILM.FILM_ID = I.FILM_ID
LEFT JOIN FILM_ACTOR AS FA ON FA.FILM_ID = FILM.FILM_ID
LEFT JOIN ACTOR AS A ON A.ACTOR_ID = FA.ACTOR_ID
LEFT JOIN CUSTOMER C ON C.CUSTOMER_ID = R.CUSTOMER_ID
WHERE A.FIRST_NAME = 'SCARLETT' AND A.LAST_NAME = 'BENING'
ORDER BY 3; 

# f) Which customers residing at postal code 62703 rented movies that were Documentaries.

SELECT C.CUSTOMER_ID,
	   C.FIRST_NAME,
       C.LAST_NAME,
       A.POSTAL_CODE,
       CAT.NAME
FROM CUSTOMER AS C
LEFT JOIN ADDRESS AS A ON A.ADDRESS_ID = C.ADDRESS_ID
LEFT JOIN STORE AS S ON S.STORE_ID = A.ADDRESS_ID
LEFT JOIN RENTAL AS R ON R.CUSTOMER_ID = C.CUSTOMER_ID
LEFT JOIN INVENTORY AS I ON I.INVENTORY_ID = R.INVENTORY_ID
LEFT JOIN FILM AS F ON F.FILM_ID = I.FILM_ID
LEFT JOIN FILM_CATEGORY AS F_CAT ON F_CAT.FILM_ID = F.FILM_ID
LEFT JOIN CATEGORY AS CAT ON CAT.CATEGORY_ID = F_CAT.CATEGORY_ID
WHERE A.POSTAL_CODE = '62703' AND CAT.NAME = 'Documentary'; # Customer #582
  
# g) Find all the addresses where the second address line is not empty (i.e., contains some text), and return these second addresses sorted.

SELECT ADDRESS,
	   ADDRESS2
FROM ADDRESS
WHERE ADDRESS2 IS NOT NULL AND ADDRESS2 <> '' # Address2 is always blank, hence 0 records returned
ORDER BY 2;

# h) How many films involve a “Crocodile” and a “Shark” based on film description ?

SELECT COUNT(FILM_ID) AS COUNT
FROM FILM
WHERE DESCRIPTION LIKE '%Crocodile%' 
  AND DESCRIPTION LIKE '%Shark%'; # 10

# i) List the actors who played in a film involving a “Crocodile” and a “Shark”, along with the release year of the movie, sorted by the actors’ last names.

SELECT DISTINCT A.FIRST_NAME,
			    A.LAST_NAME,
			    F.RELEASE_YEAR
FROM ACTOR AS A
LEFT JOIN FILM_ACTOR AS FA ON FA.ACTOR_ID = A.ACTOR_ID
LEFT JOIN FILM AS F ON F.FILM_ID = FA.FILM_ID
WHERE DESCRIPTION LIKE '%Crocodile%' 
  AND DESCRIPTION LIKE '%Shark%'
ORDER BY A.LAST_NAME;

# j) Find all the film categories in which there are between 55 and 65 films. Return the names of categories and the number of films per category, 
# sorted from highest to lowest by the number of films.

SELECT C.NAME,
	   COUNT(*) AS COUNT
FROM FILM AS F
LEFT JOIN FILM_CATEGORY AS FC ON FC.FILM_ID = F.FILM_ID
LEFT JOIN CATEGORY AS C ON C.CATEGORY_ID = FC.CATEGORY_ID
GROUP BY C.NAME
HAVING COUNT BETWEEN 55 AND 65
ORDER BY 2 DESC;

# k) In which of the film categories is the average difference between the film replacement cost and the rental rate larger than $17?

SELECT C.NAME,
	   AVG(F.REPLACEMENT_COST - F.RENTAL_RATE) AS DIFFERENCE
FROM CATEGORY AS C
LEFT JOIN FILM_CATEGORY AS FC ON C.CATEGORY_ID = FC.CATEGORY_ID
LEFT JOIN FILM AS F ON F.FILM_ID = FC.FILM_ID
GROUP BY C.NAME
HAVING AVG(F.REPLACEMENT_COST - F.RENTAL_RATE) > 17
ORDER BY 2 DESC;

# l) Many DVD stores produce a daily list of overdue rentals so that customers can be contacted and asked to return their overdue DVDs. 
# To create such a list, search the rental table for films with a return date that is NULL and where the rental date is further in the 
# past than the rental duration specified in the film table. If so, the film is overdue and we should produce the name of the film along with 
# the customer name and phone number.

SELECT F.TITLE,
	   C.FIRST_NAME,
       C.LAST_NAME,
       A.PHONE,
       DATEDIFF(NOW(), R.RENTAL_DATE) AS DIFFERENCE,
       F.RENTAL_DURATION
FROM RENTAL AS R
LEFT JOIN CUSTOMER C ON C.CUSTOMER_ID = R.CUSTOMER_ID
LEFT JOIN ADDRESS A ON A.ADDRESS_ID = C.ADDRESS_ID
LEFT JOIN INVENTORY AS I ON I.INVENTORY_ID = R.INVENTORY_ID
LEFT JOIN FILM AS F ON F.FILM_ID = I.FILM_ID
WHERE R.RETURN_DATE IS NULL 
		AND DATEDIFF(NOW(), R.RENTAL_DATE) > F.RENTAL_DURATION; # the difference between now and when the film was due is over the rental duration

# m) Find the list of all customers and staff given a store id
# Note : use a set global operator store_id, do not remove duplicates

SET @STORE_ID:= 2; # options: 1 or 2

# validate
SELECT @STORE_ID; 

SELECT CONCAT(TRIM(C.FIRST_NAME), SPACE(1), TRIM(C.LAST_NAME)) AS 'CUSTOMER_FULL_NAME',
       CONCAT(TRIM(S.FIRST_NAME), SPACE(1), TRIM(S.LAST_NAME)) AS 'STAFF_FULL_NAME',
       STORE.STORE_ID
FROM CUSTOMER AS C
LEFT JOIN STORE ON STORE.STORE_ID = C.STORE_ID
LEFT JOIN STAFF AS S ON S.STORE_ID = STORE.STORE_ID
WHERE STORE.STORE_ID = @STORE_ID;

############################### QUESTION 2 ############################### 
# a) List actors and customers whose first name is the same as the first name of the actor with ID 8.

# SELECT FIRST_NAME FROM ACTOR WHERE ACTOR_ID = 8; # First Name = MATTHEW

(SELECT DISTINCT A.ACTOR_ID AS ID,
				 A.FIRST_NAME,
				 A.LAST_NAME
FROM ACTOR AS A
WHERE A.FIRST_NAME = (SELECT FIRST_NAME
					  FROM ACTOR
                      WHERE ACTOR_ID = 8))
UNION 
(SELECT DISTINCT C.CUSTOMER_ID AS ID,
			     C.FIRST_NAME,
			     C.LAST_NAME
FROM CUSTOMER AS C 
WHERE C.FIRST_NAME = (SELECT FIRST_NAME 
					  FROM ACTOR 
                      WHERE ACTOR_ID = 8));

# b) List customers and payment amounts, with payments greater than average the payment amount

SELECT C.CUSTOMER_ID,
	   C.FIRST_NAME, 
	   C.LAST_NAME,
	   P.AMOUNT
FROM CUSTOMER AS C
LEFT JOIN PAYMENT AS P ON P.CUSTOMER_ID = C.CUSTOMER_ID
WHERE AMOUNT > (SELECT AVG(AMOUNT) 
				FROM PAYMENT) # 4.20 average
ORDER BY 4 DESC;

# c) List customers who have rented movies atleast once # Note: use IN clause

SELECT C.CUSTOMER_ID,
	   C.FIRST_NAME, 
	   C.LAST_NAME
FROM CUSTOMER AS C
WHERE C.CUSTOMER_ID IN (SELECT CUSTOMER_ID 
						FROM PAYMENT); # Customers who rented will have made at least 1 payment

# d) Find the floor of the maximum, minimum and average payment amount

SELECT FLOOR(MAX(AMOUNT)) AS MAXPAY,
	   FLOOR(MIN(AMOUNT)) AS MINPAY,
       FLOOR(AVG(AMOUNT)) AS AVGPAY
FROM PAYMENT;

############################### QUESTION 3 ############################### 
# a) Create a view called actors_portfolio which contains information about actors and films ( including titles and category).

CREATE OR REPLACE VIEW ACTORS_PORTFOLIO AS
    SELECT A.FIRST_NAME,
		   A.LAST_NAME,
           F.TITLE,
           CAT.NAME AS CATEGORY
    FROM ACTOR AS A
    LEFT JOIN FILM_ACTOR AS FA ON A.ACTOR_ID = FA.ACTOR_ID
    LEFT JOIN FILM AS F ON F.FILM_ID = FA.FILM_ID
	LEFT JOIN FILM_CATEGORY AS C ON C.FILM_ID = FA.FILM_ID
    LEFT JOIN CATEGORY AS CAT ON CAT.CATEGORY_ID = C.CATEGORY_ID;
        
# b) Describe the structure of the view and query the view to get information on the actor ADAM GRANT 

DESCRIBE ACTORS_PORTFOLIO;

SELECT * FROM ACTORS_PORTFOLIO;

# c) Insert a new movie titled Data Hero in Sci-Fi Category starring ADAM GRANT
# Note: this is feasible

# Check which are updatable
SELECT 
    table_name, is_updatable
FROM
    information_schema.views
WHERE
    table_schema = 'SAKILA';

# Note: This code will not work
# INSERT INTO ACTORS_PORTFOLIO(FIRST_NAME, LAST_NAME, TITLE, CATEGORY)
# VALUES('ADAM', 'GRANT', 'Data Hero', 'Sci-Fi'); # ERROR 1471
# Cannot insert record into View with multiple tables (JOINS). Instead, insert directly to tables then re-create View
INSERT INTO film (title, language_id)
	VALUES('Data Hero', 1);
INSERT INTO film_category (film_id, category_id)
	VALUES(1001, 14);
INSERT INTO ACTOR (FIRST_NAME, LAST_NAME, ACTOR_ID)
    VALUES('ADAM', 'GRANT', 999);
INSERT INTO film_actor (FILM_ID, ACTOR_ID)
	VALUES(1001, 999);

CREATE OR REPLACE VIEW ACTORS_PORTFOLIO AS
    SELECT A.FIRST_NAME,
		   A.LAST_NAME,
           F.TITLE,
           CAT.NAME AS CATEGORY,
           F.FILM_ID
    FROM ACTOR AS A
    LEFT JOIN FILM_ACTOR AS FA ON A.ACTOR_ID = FA.ACTOR_ID
    LEFT JOIN FILM AS F ON F.FILM_ID = FA.FILM_ID
	LEFT JOIN FILM_CATEGORY AS C ON C.FILM_ID = FA.FILM_ID
    LEFT JOIN CATEGORY AS CAT ON CAT.CATEGORY_ID = C.CATEGORY_ID;

# Confirm record was successfully added to the View
SELECT * 
FROM ACTORS_PORTFOLIO 
WHERE FILM_ID = 1001 AND LAST_NAME = 'GRANT'; 


############################### QUESTION 4 ############################### 
# a) Extract the street number ( characters 1 through 4 ) from customer addressLine1
# Note: this is a compound query <-- No ?

#Option #1
SELECT LEFT(ADDRESS, 4) # Substring can also be used
FROM ADDRESS;

#Option #2
SELECT SUBSTRING_INDEX(ADDRESS, ' ', 1)
FROM ADDRESS;

# b) Find out actors whose last name starts with character A, B or C.

SELECT FIRST_NAME,
	   LAST_NAME
FROM ACTOR
WHERE LEFT(LAST_NAME, 1) IN ('A', 'B', 'C') # could also use REGEXP '^(A|B|C)'
ORDER BY 2;

# c) Find film titles that contains exactly 10 characters

SELECT TITLE
FROM FILM
WHERE LENGTH(TITLE) = 10; # could also use REGEXP '^.{10}$' | space is counted as a character in this instance
# Option 2: WHERE LENGTH(REPLACE(title, ' ', ''))  = 10;

# d) Format a payment_date using the following format e.g "22/1/2016"

SELECT PAYMENT_DATE,
	   DATE_FORMAT(PAYMENT_DATE, "%e/%c/%Y") 
FROM PAYMENT;

# e) Find the number of days between two date values rental_date & return_date

SELECT RENTAL_ID,
	   DATEDIFF(RENTAL_DATE, RETURN_DATE) AS DIFFERENCE
FROM RENTAL
WHERE DATEDIFF(RENTAL_DATE, RETURN_DATE) IS NOT NULL
ORDER BY 2;

############################### QUESTION 5 ############################### 
# Provide 5 additional queries from the Sakila dataset and the specific business use cases they address.

# Additional Query 1: List film counts for each language
SELECT LANG.NAME,
	   COUNT(*) AS FILM_COUNT
FROM FILM AS F
LEFT JOIN LANGUAGE AS LANG ON LANG.LANGUAGE_ID = F.LANGUAGE_ID
GROUP BY LANG.NAME
ORDER BY 2 DESC;

# Additional Query 2: List stores and their customer counts
SELECT C.STORE_ID,
       COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMER AS C
LEFT JOIN STORE AS S ON C.STORE_ID = S.STORE_ID
LEFT JOIN ADDRESS AS A ON S.ADDRESS_ID = A.ADDRESS_ID
GROUP BY C.STORE_ID;

# Additional Query 3: Actors who starred in English Sci-Fi Movies
SELECT DISTINCT ACT.FIRST_NAME,
	            ACT.LAST_NAME
FROM ACTOR AS ACT
LEFT JOIN FILM_ACTOR AS FA ON ACT.ACTOR_ID = FA.ACTOR_ID
LEFT JOIN FILM ON FILM.FILM_ID = FA.FILM_ID
LEFT JOIN FILM_CATEGORY AS FC ON FC.FILM_ID = FILM.FILM_ID
LEFT JOIN CATEGORY AS C ON C.CATEGORY_ID = FC.CATEGORY_ID
WHERE FILM.LANGUAGE_ID IN (SELECT LANGUAGE_ID 
						   FROM LANGUAGE 
                           WHERE NAME = 'English') AND C.NAME = 'Sci-Fi';

# Additional Query 4: Select cheaper movies with higher rental durations

SELECT *
FROM FILM
WHERE REPLACEMENT_COST < 10 
AND RENTAL_DURATION > 1; 

# Additional Query 5: Select the top 2 most common replacement costs
SELECT REPLACEMENT_COST, 
	   COUNT(*) AS OCCURRENCES
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY 2 DESC
LIMIT 2;

