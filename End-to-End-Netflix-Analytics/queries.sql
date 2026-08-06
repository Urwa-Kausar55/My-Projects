--Netflix-Data-Analysis-Project

-- Content Type Distribution
SELECT 
    type AS content_type, 
    COUNT(*) AS total_count
FROM netflix_content
GROUP BY type
ORDER BY total_count DESC;

-- Content Rating Distribution by Type
SELECT 
    type, 
    rating, 
    COUNT(*) AS total_content
FROM netflix_content
GROUP BY type, rating
ORDER BY type, total_content DESC;

-- Year-wise Content Distribution by Type
SELECT 
    release_year, 
    type, 
    COUNT(*) AS total_content
FROM netflix_content
GROUP BY release_year, type
ORDER BY release_year DESC;

-- Top 10 Countries by Content Production 
SELECT 
    country, 
    COUNT(*) AS total_content
FROM netflix_content
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 10;

-- Top 10 Longest Duration Movies
SELECT title, duration
FROM netflix_content
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ',1) AS INT) DESC
LIMIT 10;

-- Top 10 Longest Duration Movies
SELECT title, duration
FROM netflix_content
WHERE type = 'TV Show' AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ',1) AS INT) DESC
LIMIT 10;

-- Content added in last 5 years by date
SELECT 
    date_added, 
    COUNT(*) AS Total_Content
FROM netflix_content
WHERE date_added >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY date_added
ORDER BY date_added DESC;

-- Top 10 Directors by Content Count
SELECT 
	director, 
	COUNT (*) AS total_content
FROM netflix_content
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 10;

-- TV Shows Exceeding 5 seasons
SELECT 
	title, duration
FROM netflix_content
WHERE type = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) >5;

-- Content Distribution By Genre
SELECT 
	listed_in AS genre,
	COUNT (*) AS total_count
FROM netflix_content
GROUP BY listed_in
ORDER BY total_count DESC;

-- Average Content Release Per Year By Country
SELECT 
    country, 
    COUNT(*) AS total_content,
    COUNT(DISTINCT release_year) AS years_active,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT release_year), 2) AS avg_content_per_year
FROM netflix_content
WHERE country IN (
    SELECT country 
    FROM netflix_content 
    GROUP BY country 
    ORDER BY COUNT(*) DESC 
    LIMIT 10
)
GROUP BY country
ORDER BY avg_content_per_year DESC;

-- Documentaries Content Filter
SELECT title, listed_in AS genre
FROM netflix_content
WHERE type = 'Movie'
	AND listed_in LIKE '%Documentaries%';

-- Annual Movie Release Trends
SELECT
	release_year,
	COUNT (*) AS total_movies
FROM netflix_content
WHERE type = 'Movie'
GROUP BY release_year
ORDER BY release_year DESC;

-- Annual TV Show Release Trends
SELECT
	release_year,
	COUNT (*) AS total_TVshows
FROM netflix_content
WHERE type = 'TV Show'
GROUP BY release_year
ORDER BY release_year DESC;

-- Total Movies By Specific Actor in Last Year
SELECT 
	COUNT (*) AS total_movies
FROM netflix_content
WHERE cast LIKE '%Salman Khan%'
	AND type = 'Movie'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1

-- Rank Countries by Content Production
SELECT country, COUNT(*) AS total_content,
RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM netflix_content
GROUP BY country;