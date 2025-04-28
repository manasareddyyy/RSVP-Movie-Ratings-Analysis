USE imdb;


SELECT
	*
FROM
	movie;

SELECT
	*
FROM
	ratings;

SELECT
	*
FROM
	genre;

SELECT
	*
FROM
	director_mapping;

SELECT
	*
FROM
	role_mapping;

SELECT
	*
FROM
	names;


-- Segment 1:

-- 1. Find the total number of rows in each table of the schema?
SELECT 
    COUNT(*) AS movie_row_count
FROM
    movie;
    
SELECT 
    COUNT(*) AS ratings_row_count
FROM
    ratings;
    
SELECT 
    COUNT(*) AS genre_row_count
FROM
    genre;
    
SELECT 
    COUNT(*) AS directors_row_count
FROM
    director_mapping;
    
SELECT 
    COUNT(*) AS roles_row_count
FROM
    role_mapping;
    
SELECT 
    COUNT(*) AS names_row_count
FROM
    names;


-- 2. Which columns in the 'movie' table have null values?
SELECT 
    COUNT(CASE
        WHEN title IS NULL THEN id
    END) AS title_nulls,
    COUNT(CASE
        WHEN year IS NULL THEN id
    END) AS year_nulls,
    COUNT(CASE
        WHEN date_published IS NULL THEN id
    END) AS date_published_nulls,
    COUNT(CASE
        WHEN duration IS NULL THEN id
    END) AS duration_nulls,
    COUNT(CASE
        WHEN country IS NULL THEN id
    END) AS country_nulls,
    COUNT(CASE
        WHEN worlwide_gross_income IS NULL THEN id
    END) AS worlwide_gross_income_nulls,
    COUNT(CASE
        WHEN languages IS NULL THEN id
    END) AS languages_nulls,
    COUNT(CASE
        WHEN production_company IS NULL THEN id
    END) AS production_company_nulls
FROM
    movie;
    

-- 3. Find the total number of movies released in each year. How does the trend look month-wise? (Output expected) 

SELECT 
    EXTRACT( month from date_published) as month_num, COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;

-- 4. How many movies were produced in the USA or India in the year 2019?
SELECT 
    COUNT(*) AS number_of_movies
FROM
    movie
WHERE year=2019 AND (LOWER(country) LIKE '%usa%' OR LOWER(country) LIKE '%india%');

-- 5. Find the unique list of the genres present in the data set?
SELECT DISTINCT
    genre
FROM
    genre;

/* So, RSVP Movies plans to make a movie on one of these genres.
Now, don't you want to know in which genre were the highest number of movies produced?
Combining both the 'movie' and the 'genre' table can give us interesting insights. */

-- 6.Which genre had the highest number of movies produced overall?
WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    genre
FROM
    summary
WHERE
    genre_rank = 1;


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- 7. How many movies belong to only one genre?
WITH movie_genre_summary AS
(
SELECT 
	movie_id,
	COUNT(genre) AS genre_count
FROM
	genre
GROUP BY movie_id
)
SELECT 
    COUNT(DISTINCT movie_id) AS single_genre_movie_count
FROM
    movie_genre_summary
WHERE
    genre_count=1;


/* There are more than three thousand movies which have only one genre associated with them.
This is a significant number.
Now, let's find out the ideal duration for RSVP Movies’ next project.*/

-- 8.What is the average duration of movies in each genre? 
SELECT 
    genre,
    AVG(duration) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre;

/* Now you know that movies of genre 'Drama' (produced highest in number in 2019) have an average duration of
106.77 mins.
Let's find where the movies of genre 'thriller' lie on the basis of number of movies.*/

-- 9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    *
FROM
    summary
WHERE
    lower(genre) = 'thriller';

-- Thriller movies are in the top 3 among all genres in terms of the number of movies.

-- --------------------------------------------------------------------------------------------------------------
/* In the previous segment, you analysed the 'movie' and the 'genre' tables. 
   In this segment, you will analyse the 'ratings' table as well.
   To start with, let's get the minimum and maximum values of different columns in the table */

-- Segment 2:

-- 10.  Find the minimum and maximum values for each column of the 'ratings' table except the movie_id column.
SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;
    
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating. */

-- 11. What are the top 10 movies based on average rating?
WITH top_movies AS
(
SELECT 
    m.title,
    avg_rating,
   
   RANK() OVER (ORDER BY avg_rating DESC) AS movie_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r ON m.id = r.movie_id
)
SELECT 
    *
FROM
    top_movies
WHERE
    movie_rank <= 10;
 

/* Do you find the movie 'Fan' in the top 10 movies with an average rating of 9.6? If not, please check your code
again.
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight. */

-- 12. Summarise the ratings table based on the movie counts by median ratings.
SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating;

/* Movies with a median rating of 7 are the highest in number. 
Now, let's find out the production house with which RSVP Movies should look to partner with for its next project.*/

-- 13. Which production house has produced the most number of hit movies (average rating > 8)?
WITH top_prod AS
(
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE avg_rating>8 AND m.production_company IS NOT NULL
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank = 1;

-- 14. How many movies released in each genre in March 2017 in the USA had more than 1,000 votes?
SELECT 
    genre, 
    COUNT(g.movie_id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    movie AS m 
		ON g.movie_id = m.id
			INNER JOIN
		ratings AS r 
			ON m.id = r.movie_id
WHERE
    year = 2017
        AND MONTH(date_published) = 3
        AND LOWER(country) LIKE '%usa%'
        AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;


-- 15. Find the movies in each genre that start with the characters ‘The’ and have an average rating > 8.
SELECT 
    title, 
    avg_rating,
    genre
FROM
    movie AS m 
	    INNER JOIN
    genre AS g
    	ON m.id =g.movie_id 
			INNER JOIN
		ratings AS r 
			ON m.id = r.movie_id
WHERE
    title like 'The%' AND avg_rating>8
ORDER BY genre, avg_rating DESC;

-- 16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
SELECT 
    COUNT(m.id) AS movie_count
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
WHERE
    median_rating=8 AND 
    date_published BETWEEN '2018-04-01' AND '2019-04-01';


-- Now, let's see the popularity of movies in different languages.

-- 17. Do German movies get more votes than Italian movies? 
WITH votes_summary AS
(
SELECT 
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN m.id END) AS german_movie_count,
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN m.id END) AS italian_movie_count,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN r.total_votes END) AS german_movie_votes,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN r.total_votes END) AS italian_movie_votes
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
)
SELECT 
    ROUND(german_movie_votes / german_movie_count, 2) AS german_votes_per_movie,
    ROUND(italian_movie_votes / italian_movie_count, 2) AS italian_votes_per_movie
FROM
    votes_summary;

-- Answer is Yes
-- ----------------------------------------------------------------------------------------------------------------

/* Now that you have analysed the 'movie', 'genre' and 'ratings' tables, let us analyse another table - the 'names'
table. 
Let’s begin by searching for null values in the table. */

-- Segment 3:

-- 18. Find the number of null values in each column of the 'names' table, except for the 'id' column.
SELECT 
    COUNT(CASE
        WHEN name IS NULL THEN id
    END) AS name_nulls,
    COUNT(CASE
        WHEN height IS NULL THEN id
    END) AS height_nulls,
    COUNT(CASE
        WHEN date_of_birth IS NULL THEN id
    END) AS date_of_birth_nulls,
    COUNT(CASE
        WHEN known_for_movies IS NULL THEN id
    END) AS known_for_movies_nulls
FROM
    names;
    
/* Answer: 0 nulls in name; 17335 nulls in height; 13413 nulls in date_of_birth; 15226 nulls in known_for_movies.
   There are no null values in the 'name' column. */ 

/* The director is the most important person in a movie crew. 
   Let’s find out the top three directors each in the top three genres who can be hired by RSVP Movies. */

-- 19. Who are the top three directors in each of the top three genres whose movies have an average rating > 8?
WITH top_rated_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
			INNER JOIN
		ratings AS r
			ON m.id=r.movie_id
WHERE avg_rating>8
GROUP BY genre
)
SELECT 
	n.name as director_name,
	COUNT(m.id) AS movie_count
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
					INNER JOIN
						genre AS g
					ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_rated_genres WHERE genre_rank<=3)
		AND avg_rating>8
GROUP BY name
ORDER BY movie_count DESC
LIMIT 3;

/* James Mangold can be hired as the director for RSVP's next project. You may recall some of his movies like 'Logan'
and 'The Wolverine'.
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
SELECT 
	n.name as actor_name,
	COUNT(m.id) AS movie_count
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE median_rating>=8 AND category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

/* Did you find the actor 'Mohanlal' in the list? If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- 21. Which are the top three production houses based on the number of votes received by their movies?
WITH top_prod AS
(
SELECT 
    m.production_company,
    SUM(r.total_votes) AS vote_count,
    ROW_NUMBER() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank <= 3;

/* Yes, Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received for the movies they have produced.
Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies is looking to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be. */

-- 22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the
-- list?
WITH actor_ratings AS
(
SELECT 
	n.name as actor_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actor_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actor' AND LOWER(country) like '%india%'
GROUP BY actor_name
)
SELECT *,
	RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM
	actor_ratings
WHERE movie_count>=5;

-- The top actor is Vijay Sethupathi.
-- 23.Find the top five actresses in Hindi movies released in India based on their average ratings.
WITH actress_ratings AS
(
SELECT 
	n.name as actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actress_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actress' AND LOWER(languages) like '%hindi%'
GROUP BY actress_name
)
SELECT *,
	ROW_NUMBER() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM
	actress_ratings
WHERE movie_count>=3
LIMIT 5;

-- Taapsee Pannu tops the charts with an average rating of 7.74.
-- Now let us divide all the thriller movies in the following categories and find out their numbers.
/* 24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  
			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop

--------------------------------------------------------------------------------------------*/
SELECT 
    m.title AS movie_name,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One time watch'
        ELSE 'Flop'
    END AS movie_category
FROM
    movie AS m
        LEFT JOIN
    ratings AS r ON m.id = r.movie_id
        LEFT JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    LOWER(genre) = 'thriller'
        AND total_votes > 25000
ORDER BY r.avg_rating desc;

-- -----------------------------------------------------------------------------------------------------------

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment. */

-- Segment 4:

-- 25. What is the genre-wise running total and moving average of the average movie duration? 
WITH genre_summary AS
(
SELECT 
    genre,
    ROUND(AVG(duration),2) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
SELECT *,
	SUM(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration
FROM
	genre_summary;
    
-- Rounding off is good to have and not a must have, the same thing applies to sorting.
-- Let us find the top 5 movies for each year with the top 3 genres.
-- 26. Which are the five highest-grossing movies in each year for each of the top three genres?
-- Top 3 Genres based on most number of movies
WITH top_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
,
top_grossing AS
(
SELECT 
    g.genre,
	year,
	m.title as movie_name,
    worlwide_gross_income,
    RANK() OVER (PARTITION BY g.genre, year
					ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM
movie AS m
	INNER JOIN
genre AS g
	ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres WHERE genre_rank<=3)
)
SELECT * 
FROM
	top_grossing
WHERE movie_rank<=5;

/* Finally, let’s find out the names of the top two production houses that have produced the highest number of hits
   among multilingual movies.
   
27. What are the top two production houses that have produced the highest number of hits (median rating >= 8) among
multilingual movies? */
WITH top_prod AS
(
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE median_rating>=8 AND m.production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank <= 2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0.
-- If there is a comma, that means the movie is of more than one language.
-- 28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?
WITH actress_ratings AS (
    SELECT 
		n.name as actress_name,
		SUM(r.total_votes) AS total_votes,
		COUNT(m.id) as movie_count,
		ROUND( 
			SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes), 2) 
		AS actress_avg_rating
        
    FROM
        names AS n
			INNER JOIN 
		role_mapping AS a 
			ON n.id = a.name_id
				INNER JOIN 
			movie AS m 
				ON a.movie_id = m.id
					INNER JOIN 
				ratings AS r 
					ON m.id = r.movie_id
						INNER JOIN 
					genre AS g 
						ON m.id = g.movie_id
                        
    WHERE a.category = 'actress' AND LOWER(g.genre) = 'drama' AND r.avg_rating > 8
    GROUP BY n.name
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC, actress_name) AS actress_rank
FROM 
    actress_ratings
LIMIT 3;

/* Q29. Get the following details for top 9 directors (based on number of movies):
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
Total movie duration */

WITH top_directors AS
(
SELECT 
	n.id as director_id,
    n.name as director_name,
	COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) as director_rank
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
GROUP BY n.id
),
movie_summary AS
(
SELECT
	n.id as director_id,
    n.name as director_name,
    m.id AS movie_id,
    m.date_published,
	r.avg_rating,
    r.total_votes,
    m.duration,
    LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS next_date_published,
    DATEDIFF(LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published),date_published) AS inter_movie_days
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE n.id IN (SELECT director_id FROM top_directors WHERE director_rank<=9)
)
SELECT 
	director_id,
	director_name,
	COUNT(DISTINCT movie_id) as number_of_movies,
	ROUND(AVG(inter_movie_days),0) AS avg_inter_movie_days,
	ROUND(
	SUM(avg_rating*total_votes)
	/
	SUM(total_votes)
		,2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM 
movie_summary
GROUP BY director_id
ORDER BY number_of_movies DESC, avg_rating DESC;