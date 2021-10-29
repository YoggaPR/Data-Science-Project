-- Project's dataset taken from Datacamp

use movienow;

-- DROP TABLE IF EXISTS "movies";
CREATE TABLE movies
(
    movie_id INT PRIMARY KEY,
    title TEXT,
    genre TEXT,
    runtime INT,
    year_of_release INT,
    renting_price numeric
);

-- DROP TABLE IF EXISTS "actors";
CREATE TABLE actors
(
    actor_id integer PRIMARY KEY,
    name varchar(255),
    year_of_birth integer,
    nationality varchar(255),
    gender varchar(255)
);

-- DROP TABLE IF EXISTS "actsin";
CREATE TABLE actsin
(
    actsin_id integer PRIMARY KEY,
    movie_id integer,
    actor_id integer
);

-- DROP TABLE IF EXISTS "customers";
CREATE TABLE customers
(
	customer_id integer PRIMARY KEY,
    name varchar(255),
    country varchar(255),
    gender varchar(255),
    date_of_birth date,
    date_account_start date
);

-- DROP TABLE IF EXISTS "renting";
CREATE TABLE renting
(
    renting_id integer PRIMARY KEY,
    customer_id integer NOT NULL,
    movie_id integer NOT NULL,
    rating integer,
    date_renting date
);

-- Report the income from movie rentals for each movie 
-- Use a join to get the movie title and price for each movie rental
-- Order the result by decreasing income
SELECT m.title, SUM(m.renting_price) total_income FROM renting r
JOIN movies m ON m.movie_id = r.movie_id
GROUP BY m.title
ORDER BY total_price DESC;

-- Or
SELECT rm.title, -- Report the income from movie rentals for each movie 
       SUM(rm.renting_price) AS income_movie
FROM
       (SELECT m.title,  -- Use a join to get the movie title and price for each movie rental
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id=m.movie_id) AS rm
GROUP BY rm.title
ORDER BY income_movie DESC; -- Order the result by decreasing income


-- Report for male and female actors from the USA 
-- The year of birth of the oldest actor
-- The year of birth of the youngest actor
SELECT gender, MIN(year_of_birth) as Oldest_Age, MAX(year_of_birth) as Youngest_Age FROM actors
WHERE nationality = 'USA'
GROUP BY gender;

 -- Or 
SELECT a.gender, -- Report for male and female actors from the USA 
       MIN(a.year_of_birth), -- The year of birth of the oldest actor
       MAX(a.year_of_birth) -- The year of birth of the youngest actor
FROM
   (SELECT * FROM actors -- Use a subsequen SELECT to get all information about actors from the USA
   WHERE nationality = 'USA')
   AS a -- Give the table the name a
GROUP BY a.gender;


-- Identify favorite movies for a group of customers
-- Report number of views per movie
-- Report the average rating per movie
-- Select customers born in the 70s
-- Remove movies with only one rental
-- Order with highest rating first
SELECT m.title, COUNT(m.movie_id), AVG(r.rating) avg_rating FROM renting r
JOIN movies m on m.movie_id = r.movie_id
JOIN customers c on c. customer_id = r.customer_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(m.movie_id) > 1 and avg_rating > 0
ORDER BY avg_rating DESC;

-- Or 
SELECT m.title, 
COUNT(*), -- Report number of views per movie
AVG(r.rating) -- Report the average rating per movie
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31' -- Select customers born in the 70s
GROUP BY m.title
HAVING COUNT(*) > 1 -- Remove movies with only one rental
ORDER BY AVG(r.rating) DESC; -- Order with highest rating first


-- Identify favorite actors for Spain customers
-- Select only customers from Spain
-- For each actor, separately for male and female customers
SELECT a.name, c.gender, COUNT(*), AVG(r.rating) FROM renting r
JOIN customers c ON c.customer_id = r.customer_id
JOIN actsin ac ON ac.movie_id = r.movie_id
JOIN actors a ON ac.actor_id = a.actor_id
WHERE c.country = 'Spain'
GROUP BY a.name, c.gender
HAVING COUNT(*) > 5 AND AVG(r.rating) IS NOT NULL;

-- Or
SELECT a.name,  c.gender,
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting as r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN actsin as ai
ON r.movie_id = ai.movie_id
LEFT JOIN actors as a
ON ai.actor_id = a.actor_id
WHERE c.country = 'Spain' -- Select only customers from Spain
GROUP BY a.name, c.gender -- For each actor, separately for male and female customers
HAVING AVG(r.rating) IS NOT NULL 
  AND COUNT(*) > 5 
ORDER BY avg_rating DESC, number_views DESC;


-- KPIs per country
-- The number of movie rentals
-- The average rating
-- The revenue from movie rentals
SELECT c.country, COUNT(r.renting_id), AVG(r.rating), SUM(m.renting_price) FROM renting r
JOIN movies m ON m.movie_id = r.movie_id
JOIN customers c ON c. customer_id = r.customer_id
WHERE r.date_renting >= '2019-01-01'
GROUP BY c.country;

-- Or
SELECT 
	c.country, -- For each country report
	COUNT(*) AS number_renting, -- The number of movie rentals
	AVG(r.rating) AS average_rating, -- The average rating
	SUM(m.renting_price) AS revenue -- The revenue from movie rentals
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE date_renting >= '2019-01-01'
GROUP BY c.country;


-- Often rented movies 
SELECT * FROM movies mo
WHERE mo.movie_id IN (
SELECT m.movie_id FROM movies m
JOIN renting r ON r.movie_id = m.movie_id 
GROUP BY m.movie_id
HAVING count(*) > 5);

-- Or
SELECT *
FROM movies
WHERE movie_id IN  -- Select movie IDs from the inner query
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5);    
    
-- Movies with rating above average
-- Report the movie titles of all movies with average rating higher than the total average
SELECT * FROM movies m
WHERE m.movie_id IN (
SELECT r.movie_id FROM renting r
JOIN movies mo ON mo.movie_id = r.movie_id
GROUP BY r.movie_id
HAVING AVG(r.rating) > (
	SELECT AVG(rating) FROM renting
	)
);
         
-- Or
SELECT title -- Report the movie titles of all movies with average rating higher than the total average
FROM movies
WHERE movie_id IN
	(SELECT movie_id -- Select movie IDs and calculate the average rating 
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) >  -- Of movies with rating above average
		(SELECT AVG(rating)
		 FROM renting));
         
         
-- Select all movies with average rating higher than the average rating of all movies (7.939)
SELECT m.title, m.genre, AVG(r.rating) FROM movies m
JOIN renting r ON r.movie_id = m.movie_id
GROUP BY m.title
HAVING AVG(r.rating) > (
	SELECT AVG(rating) FROM renting
);


-- Select all movies with an average rating higher than 8.
SELECT * FROM movies m
JOIN renting r ON r.movie_id = m.movie_id
GROUP BY m.title
HAVING AVG(r.rating) > 8
ORDER BY m.movie_id;
    
-- Or
SELECT *
FROM movies AS m
WHERE 8 < -- Select all movies with an average rating higher than 8
	(SELECT avg(rating)
	FROM renting AS r
	WHERE r.movie_id = m.movie_id);    
    
    
-- Select all movies with more than 5 ratings. Use the first letter of the table as an alias.
-- Select all movies with more than 5 ratings
SELECT * FROM movies m
JOIN renting r ON r.movie_id = m.movie_id
GROUP BY m.title
HAVING COUNT(r.rating) > 5
ORDER BY m.movie_id;
    
-- Or
SELECT *
FROM movies m
WHERE 5 < -- Select all movies with more than 5 ratings
	(SELECT COUNT(rating)
	FROM renting r
	WHERE r.movie_id = m.movie_id);    
    
    
-- Actors in comedies 
-- Report the nationality and the number of actors for each nationality
-- Select the records of all actors who play in a Comedy
SELECT a.nationality, COUNT(distinct a.actor_id) FROM actsin ai
JOIN actors a ON ai.actor_id = a.actor_id
JOIN movies m ON m.movie_id = ai.movie_id
WHERE m.genre = 'Comedy' AND ai.actor_id = a.actor_id
GROUP BY a.nationality;

-- Or
SELECT a.nationality, COUNT(*) -- Report the nationality and the number of actors for each nationality
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id -- Select the records of all actors who play in a Comedy
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP BY a.nationality;


-- Young actors not coming from the USA 
-- Select all actors who are not from the USA and all actors who are born after 1990
SELECT * FROM actors a
WHERE a.nationality <> 'USA'
OR a.year_of_birth > 1990;


-- Dramas with high ratings
-- Select all movies of genre drama with average rating higher than 7
SELECT m.movie_id, m.title, m.genre, AVG(r.rating) FROM renting r
JOIN movies m ON m.movie_id = r.movie_id
WHERE m.genre = 'Drama'
GROUP BY m.movie_id, m.title, m.genre
HAVING AVG(r.rating) > 7;


-- Analyzing average ratings per country and genre
SELECT c.country, m.genre, AVG(r.rating) avg_rating, CASE WHEN AVG(r.rating) > 0 THEN AVG(r.rating)
ELSE 0 END AS avg_rating_noNull, COUNT(r.rating) FROM customers c
JOIN renting r ON c.customer_id = r.customer_id
JOIN movies m ON r.movie_id = m.movie_id
GROUP BY c.country, m.genre
ORDER BY c.country, m.genre;


-- Number of customers
-- Count the total number of customers, the number of customers for each country, and the number of female and male customers for each country
SELECT c.country, c.gender, COUNT(*) FROM customers c
GROUP BY c.country, c.gender;


-- Analyzing preferences of genres across countries
SELECT c.country, m.genre, AVG(r.rating) avg_rating, COUNT(r.renting_id) num_renting FROM renting r
LEFT JOIN customers c ON r.customer_id = c.customer_id
LEFT JOIN movies m ON r.movie_id = m.movie_id
GROUP BY c.country, m.genre
ORDER BY c.country, m.genre;


-- Exploring rating by country and gender
SELECT c.country, c.gender, AVG(r.rating) avg_rating FROM renting r
JOIN customers c ON r.customer_id = c.customer_id
GROUP BY c.country, c.gender
ORDER BY c.country, c.gender;


-- Customer preference for genres
SELECT m.genre, AVG(r.rating) avg_rating, COUNT(r.renting_id) FROM renting r
JOIN movies m ON m.movie_id = r.movie_id
WHERE r.movie_id IN (
	SELECT movie_id FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 3
)
AND r.date_renting >= '2018-01-01'
GROUP BY m.genre
ORDER BY avg_rating;


-- Customer preference for actors
SELECT a.nationality, a.gender, COUNT(r.renting_id) num_rentals, AVG(r.rating) FROM actors a
JOIN actsin ai ON ai.actor_id = a.actor_id
JOIN renting r ON r.movie_id = ai.movie_id
WHERE r.movie_id IN(
	SELECT movie_id FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 4
)
AND r.date_renting > '2018-04-01'
GROUP BY a.nationality, a.gender
ORDER BY a.nationality, a.gender, num_rentals;
