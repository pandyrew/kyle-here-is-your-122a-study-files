The Schema: "Streamify"
users(user_id, user_name, country, subscription_type)

content(content_id, title, genre, release_year, rating)

plays(user_id, content_id, play_date, duration_minutes)

directors(director_id, director_name)

directedBy(director_id, content_id)


Write a query to find the names of all users who have watched a 'Sci-Fi' 
movie released after 2022. Ensure each name appears only once.

select distinct user_name 
from users u
join plays p on p.user_id = u.user_id
join content c on c.content_id = p.content_id
where c.release_year > 2022;


Find the titles of all movies that have a rating higher than the 
average rating of all movies in the 'Comedy' genre.

select title from content c1
where c1.rating > (select avg(c2.rating) from content c2 where c2.genre = 'Comedy' )


For each country, find the user_name of the user who has spent the most 
total time (sum of duration_minutes) watching content.

SELECT t1.country, t1.user_name
FROM (
    -- Step 1: Get total time per user/country
    SELECT u.country, u.user_name, SUM(p.duration_minutes) as total_time
    FROM Users u
    JOIN Plays p ON u.user_id = p.user_id
    GROUP BY u.country, u.user_name
) t1
WHERE t1.total_time = (
    -- Step 2: Match that time against the MAX time for that specific country
    SELECT MAX(total_time_sub)
    FROM (
        SELECT u2.country, SUM(p2.duration_minutes) as total_time_sub
        FROM Users u2
        JOIN Plays p2 ON u2.user_id = p2.user_id
        GROUP BY u2.user_id, u2.country
    ) t2
    WHERE t2.country = t1.country
);


select t1.country, t1.user_name
from (
    select u.country, u.user_name, SUM(p.duration_minutes) as total_time
    from users u
    join plays p on u.user_id = p.user_id
    group by u.country, u.user_name
) t1
where t1.total_time = (
    select max(total_time_sub)
    from (
        select u2.country, SUM(p2.duration_minutes) as total_time_sub
        from users u2
        join plays p2 on u2.user_id = p2.user_id
        group by u2.user_id, u2.country
    ) t2
    where t2.country = t1.country
);


users(user_id, user_name, country, subscription_type)

content(content_id, title, genre, release_year, rating)

plays(user_id, content_id, play_date, duration_minutes)

directors(director_id, director_name)

directedBy(director_id, content_id)


Find the names of users who have watched every movie directed by 'Christopher Nolan'.

select u.user_name 
from users u
where not exists (
    select 1
    from content c
    join directedBy db on c.content_id = db.content_id
    where db.director_id = 'CN'
    and not exists (
        select 1 
        from plays p
        where p.user_id = u.user_id
        and p.content_id = c.content_id
    )
)


Find the genre that has the highest number of total plays in the year 2025.



select c.genre
from content c
join plays p on p.content_id = c.content_id
where p.play_date >= '2025-01-01' and p.play_date <= '2025-12-31'
group by c.genre
order by count(p.user_id) desc
limit 1;
