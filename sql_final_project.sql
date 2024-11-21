--statistical data 

-- Number of series produced by each country

select c.country_name,COUNT(s.ID) as number_of_series
from Shows s join countries c on s.country_1_Index=c.country_id
where s.Type='series'
group by c.country_name
order by number_of_series desc
---------------------------------------------------------------------------------------------------------
--Number of films produced by each country

select c.country_name,COUNT(s.ID) as number_of_films
from Shows s join countries c on s.country_1_Index=c.country_id
where s.Type='Movie'
group by c.country_name
order by number_of_films desc
----------------------------------------------------------------------------------------------------------
-- Number of shows for each type

select c.country_name,g.genre_name,COUNT(s.ID) as number_of_shows
from Shows s join countries c on s.country_1_Index=c.country_id
join genres g on s.genre_1_Index=g.genre_id
group by c.country_name,g.genre_name
order by number_of_shows desc
-------------------------------------------------------------------------------
-- Most rated films

select title,rating,votes
from shows
where rating IS NOT NULL and type='Movie'
order by rating desc,votes desc

--it is clear that the films with the highest number of votes and ratings is : (The Lord of the Rings: The Return of the King) with a number of votes (1677017)
--we recommend investing in these films with high ratings
------------------------------------------------------------------------------------------------------
-- Most rated series

select title,rating,votes
from shows
where rating IS NOT NULL and type='series'
order by rating desc,votes desc

--it is clear that the films with the highest number of votes and ratings is : (Breaking Bad) with a number of votes (1523446)
--we recommend investing in these series with high ratings
------------------------------------------------------------------------------------------------------

-- The countries that produce the most series with a large number of episod

select c.country_name,count(s.ID) as number_of_shows,
avg(s.Episodes) as avg_number_of_episodes,
avg(s.Rating) as avg_rating,
sum(s.Votes) as total_votes,
AVG(s.Run_Time) as avg_run_time
from shows s join countries c on s.country_1_index=c.country_id
where s.Type='Series'
group by c.country_name
having AVG(s.Episodes)>10
order by avg_rating desc

-- it turns out that the country that always has high ratings is (China) with a rate of(9.3)
--we advise directors that the number of episodes of the series should not be more than 50 and not less than 30 as this way the rating is always increasing
---------------------------------------------------------------------------------
-- The most popular types according to votes

select g.genre_name,COUNT(s.ID) AS total_shows , sum(s.votes) AS total_votes
from shows s join genres g on s.genre_1_index=g.genre_id
where s.votes IS NOT NULL 
group by g.genre_name
order by total_votes desc

-- it is clear that the most popular types of films is the (Action) types films, as the number of ratings reached (37988008)
-- we recommend increasing production in (action) type films that always get high ratings
----------------------------------------------------------------------------------
-- Top rated shows by year 

select s.Start_Year,g.genre_name,count(s.id) as number_of_shows,
avg(s.Rating) as average_rating,sum(s.Votes) as total_votes
from shows s join genres g on s.genre_1_Index=g.genre_id
group by s.Start_Year,g.genre_name
order by s.Start_Year desc,number_of_shows desc

-- we note that from 2008 to 2013, crime-type films were the most rated
-- we recommend watching this type of films that were shown during that period
----------------------------------------------------------------------------------
-- Average ratings for shows per country

select c.country_name,AVG(s.Rating) AS avg_rating
from shows s join countries c on s.country_1_index=country_id
where s.rating is not null 
group by c.country_name
order by avg_rating desc

-- it is clear that the most countries that received ratings is (New Zealand) with a percentage of ratings (8.049)
-- we advise allocating marketing campaigns in this most productive country
-----------------------------------------------------
-- The most rated shows that exceed two hours or less


select
      case 
	      when Run_Time >120 Then 'long films(>2 hours)'
		  else 'short films(<2 hours)'
      end as film_lenght
,COUNT(ID) As total_shows
,avg(Rating) As average_rating
from shows 
where Type='Movie' and rating is not null 
group by 
     case 
	      when Run_Time >120 Then 'long films(>2 hours)'
		  else 'short films(<2 hours)'
      end 
order by film_lenght desc

--it turns out that most films always receive high ratings,especially films that exceed two hours in lenght
-- we recommend increasing the production of films that exceed two hours in lenght as they are the most highly rated
------------------------------------------------------------------------------
-- Old or new movies? 
with Movies_By_Period as(
select 
      case 
	      when start_year between 1980 and 1989 then '1980-1989'
		  when start_year between 1990 and 1999 then '1990-1999'
		  when start_year between 2000 and 2009 then '2000-2009'
		  when start_year between 2010 and 2019 then '2010-2019'
		  when start_year between 2020 and 2029 then '2020-2029'
		  else 'before 1980'
     end as period,
	 avg(rating) as avg_rating,
	 count(ID) as number_of_Movies
from shows 
where type='Movie'
group by 
         case 
	      when start_year between 1980 and 1989 then '1980-1989'
		  when start_year between 1990 and 1999 then '1990-1999'
		  when start_year between 2000 and 2009 then '2000-2009'
		  when start_year between 2010 and 2019 then '2010-2019'
		  when start_year between 2020 and 2029 then '2020-2029'
		  else 'before 1980'
     end 
)
select period
	 ,avg_rating,number_of_Movies,LAG(avg_rating) over (order by period) as previous_period_rating,
	 (avg_rating-LAG(avg_rating) over (order by period)) as rating_difference
	 
from Movies_By_Period
order by period
-- we note that the films before the 1980s or in the 1980s are the period that received a high rating
-- we recommend watching these films in the 1980s and before it with high rating 
----------------------------------------------------------------------------------------
-- Do films that get high votes always get high ratings?
select 
      case
	      when Votes >=10000 then 'high votes (>=10,000)'
		  when Votes between 1000 and 9999 then 'Moderate votes (1,000 - 9,999)'
		  else 'low votes (<1,000)' 
      end as votes_category,
	  avg(Rating) as average_rating
	  ,count(ID) as Number_of_films
from Shows
where type='Movie' and Rating is not null 
and Votes is not null
group by  
      case
	      when Votes >=10000 then 'high votes (>=10,000)'
		  when Votes between 1000 and 9999 then 'Moderate votes (1,000 - 9,999)'
		  else 'low votes (<1,000)'
      end

--it turns out that films that get high ratings always get high votes 
----------------------------------------------------------------------------------------------
-- The most used languages in movies and series

select l.Lnaguage_name,COUNT(s.ID) as number_of_shows, avg(s.Rating) as rating
from Shows s join languages l on s.language_1_Index=l.Language_id
group by l.Lnaguage_name
order by number_of_shows desc

-- it is clear that the most commonly used language in films,which achieves a high rating when used,is(English) with a rating (7.049)
-- we recommend focusing on the most highly rated languages,such as(Malayaiam)
------------------------------------------------------------------------------------------------


