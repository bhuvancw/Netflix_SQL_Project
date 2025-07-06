drop table if exists netflix;
create table netflix
	(
	show_id varchar(10),
	type varchar(20),
	title varchar(150),
	director varchar(250),
	casts varchar(800),
	country	varchar(150),
	date_added varchar(30),
	release_year int,
	rating varchar(20),
	duration varchar(30),
	listed_in varchar(100),
	description varchar(300)
	);

select * from netflix;

select count(*) as total_content from netflix;

select distinct type from netflix;

select * from netflix;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select type, count(*) from netflix group by type;

-- 2. Find the most common rating for movies and TV shows

select * from
(select 
	type,
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as rank
from netflix 
	group by
		1,2)
where rank=1;

-- 3. List all movies released in a specific year (e.g., 2020)

select 
	* 
from netflix
	where type='Movie' and release_year=2020;
	
-- 4. Find the top 5 countries with the most content on Netflix

select 
	trim(unnest(string_to_array(country,','))) as new_country,
	count(show_id)
from netflix
	group by 1
	order by 2 desc
	limit 5;


-- 5. Identify the longest movie

select 
	*
from netflix 
where
	type='Movie'
	and
	duration=(select max(duration) from netflix);
		

-- 6. Find content added in the last 5 years

select 
	*
from netflix
where 
	to_date(date_added,'Month DD,YEAR')>=current_date-interval '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select
	*
from netflix
where
	director ilike '%Rajiv Chilaka%';

	
-- 8. List all TV shows with more than 5 seasons

select * from netflix
where
	cast(split_part(duration,' ',1) as integer)>5
	and type='TV Show';

---------------------------- OR -------------------------
select * from netflix
where
	split_part(duration,' ',1)::numeric >5
	and type='TV Show';

-- 9. Count the number of content items in each genre

select
	listed_in,
	trim(unnest(string_to_array(listed_in,','))), 
	show_id
from netflix;

select 
	trim(unnest(string_to_array(listed_in,','))), 
	count(*)
from netflix
	group by 1 order by 2 desc;


-- 10. Find each year and the average numbers of content release in India on netflix.
--	   Return top 5 year with highest avg content release

with new_netflix as
(select
	release_year,
	trim(unnested_country) as country
from netflix,
unnest(string_to_array(country,',')) as unnested_country)
select 
	release_year,
	count(*)
from new_netflix
WHERE
	country='India'
	group by 1
	order by 2 desc
	limit 5
;

	
-- 11. List all movies that are documentaries

select
	*
from netflix
where listed_in ilike '%documentaries%'


-- 12. Find all content without a director

select * from netflix where director isnull;


13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select
	*
from netflix
	where casts ilike '%Salman Khan%'
	and
	release_year> extract(year from current_date)-10;

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
	trim(unnest(string_to_array(casts,','))) as actors,
	count(*) as total_movies
from netflix
	where
		country ilike '%india%'
	group by 1
	order by 2 desc
	limit 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category.

with cat AS 
(
select *,
	case
		when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
		else 'Good'
	end as category
from netflix
)
select category,count(*) from cat group by 1;