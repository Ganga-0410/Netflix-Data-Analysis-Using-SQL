CREATE TABLE netflix_titles(
    show_id VARCHAR2(10) PRIMARY KEY,
    type VARCHAR2(20),
    title VARCHAR2(255),
    director VARCHAR2(255),
    cast VARCHAR2(2000),
    country VARCHAR2(255),
    date_added varchar2(100),
    release_year NUMBER(4),
    rating VARCHAR2(20),
    duration VARCHAR2(50),
    listed_in VARCHAR2(500),
    description CLOB
);

select show_id, country from netflix_titles ;

--Q1) count the number of movies v/s tv shows
select type, count(*)
from netflix_titles
group by type;

--Q2) Find the Most Common Rating for Movies and TV Shows
with rank_movies_tv as
(
select type, rating, count(*) as count_of_rating, rank() over(partition by type order by count(*) desc) as rnk
from netflix_titles
group by type, rating
order by type, count(*) desc
)
select type, rating, count_of_rating
from rank_movies_tv
where rnk = 1;

--Q3) List All Movies Released in a Specific Year (e.g., 2020)
select title
from netflix_titles
where release_year = 2020;

--Q4) Find the Top 5 Countries with the Most Content on Netflix.
with top_country as
(
select country, count(*) as rating_count, rank() over(order by count(*) desc) as rnk
from netflix_titles
where country is not null
group by country
order by count(*) desc
)
select *
from top_country
where rnk <= 5;

--Q5)Identify the Longest Movie
with long_movie as
(SELECT title, duration, rank() over(ORDER BY TO_NUMBER(REGEXP_SUBSTR(duration, '^\d+')) DESC) as rnk
FROM netflix_titles
WHERE type = 'Movie' and duration is not null)
select * from long_movie
where rnk=1;

--Q6)Find Content Added in the Last 5 Years
SELECT type, title, date_added
FROM netflix_titles
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= SYSDATE - INTERVAL '5' YEAR;

--Q7) Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select type, title, director
from netflix_titles
where lower(director) like lower('%Rajiv Chilaka%');

--Q8)List All TV Shows with More Than 5 Seasons
SELECT type, title, duration
FROM netflix_titles
WHERE type = 'TV Show' 
AND TO_NUMBER(REGEXP_SUBSTR(duration, '^\d+')) > 5;

--Q9)Count the Number of Content Items in Each Genre(listed_in)
SELECT genre, COUNT(*) AS genre_count
FROM (
    SELECT REGEXP_SUBSTR(listed_in, '[^,]+', 1, LEVEL) AS genre
    FROM netflix_titles
    CONNECT BY REGEXP_SUBSTR(listed_in, '[^,]+', 1, LEVEL) IS NOT NULL
    AND PRIOR title = title
    AND PRIOR DBMS_RANDOM.VALUE IS NOT NULL
)
GROUP BY genre
ORDER BY genre_count DESC;

--Q10) Find each year and the average numbers of content release in India on netflix.
select 
    extract(year from to_date(date_added, 'Month DD, YYYY')) as years, 
    count(show_id) as content_added, 
    round((count(show_id)/(select count(show_id) from netflix_titles where country = 'India'))*100, 2) as avg_releases
from netflix_titles
where extract(year from to_date(date_added, 'Month DD, YYYY')) is not null
group by extract(year from to_date(date_added, 'Month DD, YYYY'));

--Q11) List All Movies that are Documentaries
select title
from netflix_titles
where listed_in like '%Documentaries%';

--Q12)Find All Content Without a Director
select *
from netflix_titles
where director is null;

--Q13) Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select type, title, release_year
from netflix_titles
where cast like '%Salman Khan%'
And release_year >= extract(year from sysdate) - 10;

--Q14)Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select actor, count(*)
from (SELECT REGEXP_SUBSTR(cast, '[^,]+', 1, LEVEL) AS actor
        FROM netflix_titles
        CONNECT BY REGEXP_SUBSTR(cast, '[^,]+', 1, LEVEL) IS NOT NULL
        AND PRIOR title = title
        AND PRIOR DBMS_RANDOM.VALUE IS NOT NULL)
where actor is not null
group by actor
order by count(*) desc
FETCH FIRST 10 ROWS ONLY;

--Q15) Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
)
GROUP BY category;






