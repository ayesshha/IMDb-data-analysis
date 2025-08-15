-- Total Movies per Year------------------------------------------------------------
SELECT year,COUNT(*) AS total_movies
FROM movies
GROUP BY year
ORDER BY year;

-- Most Active Actors------------------------------------------------------------------
SELECT a.first_name, a.last_name, COUNT(*) AS movie_count
FROM actors a
JOIN roles r ON a.id=r.actor_id
GROUP BY a.id
ORDER BY movie_count DESC
LIMIT 10;

-- Top Genres by Number of Movies-----------------------------------------------------
SELECT genre, COUNT(*) AS total_movies
FROM movies_genres
GROUP BY genre
ORDER BY total_movies DESC
LIMIT 5;

-- gender distribution of Actors------------------------------------------------------
SELECT gender, COUNT(*) AS count
FROM actors
GROUP BY gender;

-- Higehest Rated Movies per Genre---------------------------------------------------
SELECT mg.genre, m.name , MAX(m.rankscore) AS top_rankscore
FROM movies_genres mg
JOIN movies m ON mg.movie_id = m.id
GROUP BY mg.genre, m.movie;

-- Director with the most Movies-----------------------------------------------------
SELECT d.first_name, d.last_name, COUNT(*) AS total_movies
FROM directors d
JOIN movies_directors md ON d.id = md.director_id
GROUP BY d.id
ORDER BY total_movies DESC;

-- Average rankscore by genre--------------------------------------------------------
SELECT mg.genre, ROUND(AVG(m.score), 2) AS avg_score
FROM movie_genre mg
JOIN movies m ON mg.movie_id = m.id
GROUP BY mg.genre
ORDER BY avg_score DESC;

-- Actors who worked in more than 1 genre--------------------------------------------
SELECT a.first_name, a.last_name, COUNT(DISTINCT mg.genre) AS genres_worked
FROM actors a
JOIN roles r ON a.id = r.actor_id
JOIN movies_genres mg ON r.movie_id = mg.movie_id
GROUP BY a.id
HAVING genres_worked > 1
ORDER BY genres_worked DESC
LIMIT 10;

-- Ranking Movies by Score Within Year------------------------------------------------
SELECT 
      name,
      year,
      rankscore,
	RANK()OVER (PARTITION BY year ORDER BY rankscore DESC) AS rank_within_year
FROM movies;

-- Most Frequent Actor-Director Pairings---------------------------------------------
WITH actor_director_pairs AS (
  SELECT
    r.actor_id,
    md.director_id,
    COUNT(*) AS collaborations
  FROM roles r
  JOIN movies_directors md ON r.movie_id = md.movie_id
  GROUP BY r.actor_id, md.director_id
)
SELECT 
  a.first_name AS actor_first,
  a.last_name AS actor_last,
  d.first_name AS director_first,
  d.last_name AS director_last,
  collaborations
FROM actor_director_pairs adp
JOIN actors a ON adp.actor_id = a.id
JOIN directors d ON adp.director_id = d.id
ORDER BY collaborations DESC
LIMIT 5;

-- Movies with Above-Average Score -------------------------------------------------
SELECT *
FROM movies
WHERE rankscore > (
  SELECT AVG(rankscore) FROM movies
)
ORDER BY rankscore DESC;

-- Average Number of Movies per Director by Genre----------------------------------
SELECT 
    genre, 
    ROUND(AVG(movie_count), 2) AS avg_movies
FROM (
    SELECT 
        d.id, 
        dg.genre AS genre, 
        COUNT(md.movie_id) AS movie_count
    FROM directors d
    JOIN directors_genres dg 
        ON d.id = dg.director_id
    JOIN movies_directors md 
        ON d.id = md.director_id
    GROUP BY d.id, dg.genre
) AS genre_movie_counts
GROUP BY genre;

-- Movies Directed by Only One Director---------------------------------------------
SELECT m.name, COUNT(md.director_id) AS director_count
FROM movies m
JOIN movies_directors md ON m.id = md.movie_id
GROUP BY m.id
HAVING director_count = 1;

-- Most Popular Role Names--------------------------------------------------------
SELECT role, COUNT(*) AS count
FROM roles
GROUP BY role
ORDER BY count DESC
LIMIT 10;

-- Directors Who Directed Movies in Multiple Genres---------------------------------
SELECT d.first_name, d.last_name, COUNT(DISTINCT mg.genre) AS genre_count
FROM directors d
JOIN movies_directors md ON d.id = md.director_id
JOIN movies_genres mg ON md.movie_id = mg.movie_id
GROUP BY d.id
HAVING genre_count > 1
ORDER BY genre_count DESC;

-- Top Actor Pairs Who Frequently Co-Act--------------------------------------------
CREATE INDEX idx_roles_movie_actor ON roles(movie_id, actor_id);
SELECT 
    a1.first_name AS actor1_first, 
    a1.last_name  AS actor1_last,
    a2.first_name AS actor2_first, 
    a2.last_name  AS actor2_last,
    COUNT(*) AS movies_together
FROM (
    SELECT movie_id
    FROM roles
    GROUP BY movie_id
    HAVING COUNT(actor_id) < 20 
) AS small_cast
JOIN roles r1 
    ON small_cast.movie_id = r1.movie_id
JOIN roles r2 
    ON small_cast.movie_id = r2.movie_id 
    AND r1.actor_id < r2.actor_id
JOIN actors a1 
    ON r1.actor_id = a1.id
JOIN actors a2 
    ON r2.actor_id = a2.id
GROUP BY r1.actor_id, r2.actor_id
ORDER BY movies_together DESC
LIMIT 10;

-- Movies Without Any Genre Assigned---------------------------------------------------
SELECT m.id, m.name
FROM movies m
LEFT JOIN movies_genres mg ON m.id = mg.movie_id
WHERE mg.genre IS NULL;

-- Directors Who Worked with the Highest Variety of Actors----------------------------
SELECT d.first_name, d.last_name, COUNT(DISTINCT r.actor_id) AS unique_actors
FROM directors d
JOIN movies_directors md ON d.id = md.director_id
JOIN roles r ON md.movie_id = r.movie_id
GROUP BY d.id
ORDER BY unique_actors DESC
LIMIT 5;



