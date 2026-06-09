-- ============================================================
-- SECTION 1: SQL PATTERNS REFERENCE
-- ============================================================
--
-- Schema: MusicStream
--
-- users(user_id, username, country, subscription_type)
-- artists(artist_id, artist_name, genre)
-- songs(song_id, title, artist_id, duration_seconds, release_year)
-- playlists(playlist_id, user_id, playlist_name, created_date)
-- playlist_songs(playlist_id, song_id)
-- listens(user_id, song_id, listen_date, duration_played)
--
-- ============================================================


-- PATTERN 1: Basic JOIN across multiple tables
-- Find the username and song title for every listen.

SELECT u.username, s.title
FROM users u
JOIN listens l ON l.user_id = u.user_id
JOIN songs s ON s.song_id = l.song_id


-- PATTERN 2: DISTINCT to remove duplicates
-- Find all countries that have at least one user who has listened to a song.

SELECT DISTINCT u.country
FROM users u
JOIN listens l ON l.user_id = u.user_id


-- PATTERN 3: WHERE with a scalar subquery
-- Find songs with a duration longer than the average duration of all songs.

SELECT title
FROM songs
WHERE duration_seconds > (SELECT AVG(duration_seconds) FROM songs)


-- PATTERN 4: IN / NOT IN with a subquery
-- Find usernames of users who have NEVER listened to any song.

SELECT username
FROM users
WHERE user_id NOT IN (SELECT user_id FROM listens)


-- PATTERN 5: Aggregate functions (COUNT, SUM, AVG, MAX, MIN)
-- For each artist, find the number of songs they have and their average song duration.

SELECT a.artist_name,
       COUNT(s.song_id) AS num_songs,
       AVG(s.duration_seconds) AS avg_duration
FROM artists a
JOIN songs s ON s.artist_id = a.artist_id
GROUP BY a.artist_id, a.artist_name


-- PATTERN 6: HAVING to filter on aggregates
-- Find artists who have more than 5 songs released after 2020.

SELECT a.artist_name
FROM artists a
JOIN songs s ON s.artist_id = a.artist_id
WHERE s.release_year > 2020
GROUP BY a.artist_id, a.artist_name
HAVING COUNT(s.song_id) > 5


-- PATTERN 7: Correlated subquery (comparing against own group's aggregate)
-- Find songs that have a duration longer than the average duration
-- of other songs by the same artist.

SELECT s1.title, s1.duration_seconds
FROM songs s1
WHERE s1.duration_seconds > (
    SELECT AVG(s2.duration_seconds)
    FROM songs s2
    WHERE s2.artist_id = s1.artist_id
)


-- PATTERN 8: EXISTS / NOT EXISTS
-- Find users who have listened to at least one song in the 'Jazz' genre.

SELECT u.username
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM listens l
    JOIN songs s ON s.song_id = l.song_id
    JOIN artists a ON a.artist_id = s.artist_id
    WHERE l.user_id = u.user_id
    AND a.genre = 'Jazz'
)


-- PATTERN 9: EXCEPT (set difference)
-- Find user_ids who have created a playlist but have never listened to any song.

SELECT user_id FROM playlists
EXCEPT
SELECT user_id FROM listens


-- PATTERN 10: NOT EXISTS + EXCEPT = "for all" / universal quantification
-- Find users who have listened to EVERY song by artist_id = 7.
-- Idiom: user u is in result if there is NO song by that artist that u has NOT listened to.

SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT s.song_id
    FROM songs s
    WHERE s.artist_id = 7
    EXCEPT
    SELECT l.song_id
    FROM listens l
    WHERE l.user_id = u.user_id
)

-- Equivalent using double NOT EXISTS:
SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM songs s
    WHERE s.artist_id = 7
    AND NOT EXISTS (
        SELECT 1
        FROM listens l
        WHERE l.user_id = u.user_id
        AND l.song_id = s.song_id
    )
)


-- PATTERN 11: LEFT JOIN (keep rows even when there is no match)
-- For every user, show how many songs they have listened to (0 if none).

SELECT u.username, COUNT(l.song_id) AS total_listens
FROM users u
LEFT JOIN listens l ON l.user_id = u.user_id
GROUP BY u.user_id, u.username


-- PATTERN 12: Subquery in FROM (derived / inline table)
-- For each country, find the user who has the most total listens.

SELECT t1.country, t1.username
FROM (
    SELECT u.country, u.username, COUNT(l.song_id) AS total_listens
    FROM users u
    JOIN listens l ON l.user_id = u.user_id
    GROUP BY u.country, u.user_id, u.username
) t1
WHERE t1.total_listens = (
    SELECT MAX(total_listens)
    FROM (
        SELECT u2.country, COUNT(l2.song_id) AS total_listens
        FROM users u2
        JOIN listens l2 ON l2.user_id = u2.user_id
        GROUP BY u2.country, u2.user_id
    ) t2
    WHERE t2.country = t1.country
)


-- PATTERN 13: ALL (compare against every value in a set)
-- Find the artist(s) with the smallest total number of listens across all their songs.

SELECT a.artist_name
FROM artists a
JOIN songs s ON s.artist_id = a.artist_id
JOIN listens l ON l.song_id = s.song_id
GROUP BY a.artist_id, a.artist_name
HAVING COUNT(l.user_id) <= ALL (
    SELECT COUNT(l2.user_id)
    FROM songs s2
    JOIN listens l2 ON l2.song_id = s2.song_id
    GROUP BY s2.artist_id
)


-- PATTERN 14: LIMIT / OFFSET for Nth highest
-- Find the song(s) with the 2nd highest duration.

SELECT title, duration_seconds
FROM songs
WHERE duration_seconds = (
    SELECT DISTINCT duration_seconds
    FROM songs
    ORDER BY duration_seconds DESC
    LIMIT 1 OFFSET 1
)


-- PATTERN 15: Date filtering
-- Find all listens that happened in the year 2024.

SELECT u.username, s.title, l.listen_date
FROM listens l
JOIN users u ON u.user_id = l.user_id
JOIN songs s ON s.song_id = l.song_id
WHERE l.listen_date >= '2024-01-01' AND l.listen_date <= '2024-12-31'


-- PATTERN 16: NOT EXISTS for "do not supply any X that violates condition"
-- (negation of an existence check on the supplier's own items)
-- Find users who have NOT listened to any song longer than 300 seconds.

SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM listens l
    JOIN songs s ON s.song_id = l.song_id
    WHERE l.user_id = u.user_id
    AND s.duration_seconds > 300
)


-- ============================================================
-- SECTION 2: PRACTICE PROBLEMS
-- ============================================================
--
-- Schema (same as above):
-- users(user_id, username, country, subscription_type)
-- artists(artist_id, artist_name, genre)
-- songs(song_id, title, artist_id, duration_seconds, release_year)
-- playlists(playlist_id, user_id, playlist_name, created_date)
-- playlist_songs(playlist_id, song_id)
-- listens(user_id, song_id, listen_date, duration_played)
--
-- ============================================================


-- Q1 [Easy]
-- Find the title and release_year of every song in the 'Pop' genre.
-- (Hint: join songs and artists)

select s.title, s.release_year
from songs s
natural join artists
where genre = "Pop";


-- Q2 [Easy]
-- Find the usernames of all users from 'Canada'.
-- Make sure there are no duplicates.

select distinct username
from users
where country = "Canada";


-- Q3 [Easy-Medium]
-- For each genre, count how many songs belong to it.
-- Show the genre and the count, ordered from most to least.

select a.genre, count(s.song_id) as song_count
from artists as a
natural join songs as s
group by a.genre
order by song_count desc;


-- Q4 [Medium]
-- Find the usernames of users who have listened to at least 10 distinct songs.

select u.username
from users as u
natural join listens as l
group by u.username
having count(distinct l.song_id) >= 10;

-- Q5 [Medium]
-- Find the title of every song that has been listened to more than
-- the average number of listens per song.
-- (Hint: count listens per song, compare against the average of those counts)

select s.title
from songs as s
natural join listen as l
group by s.title
having count(*) > (
    select avg(listen_counts)
    from (
        select count(*) as listen_counts
        from songs as s2
        natural join listens as l2
        group by s2.song_id
    ) as counts
)


-- Q6 [Medium]
-- For each playlist, show the playlist_name and the number of songs in it.
-- Include playlists that have zero songs.

select p.playlist_name, count(*)
from playlists p
natural join playlist_songs ps
group by p.playlist_id, p.playlist_name




-- Q7 [Medium-Hard]
-- Find usernames of users who have listened to songs released in EVERY year
-- from 2020 to 2024 (i.e., they have at least one listen for each of those years).
-- (Hint: count distinct release years heard that fall in that range, compare to 5)

select u.username
from users u
natural join listens l
natural join songs s
where s.release_year between 2020 and 2024
group by u.user_id, u.username
having count(distinct s.release_year) = 5



-- Q8 [Medium-Hard]
-- Find artists (artist_name) such that every song they have ever released
-- has been listened to at least once.
-- (Hint: there should be no song by this artist with zero listens)

select a.artist_name
from artists a
where not exists (
    select s.song_id
    from songs s
    where s.artist_id = a.artist_id
    except
    select s.song_id
    from listens l
    where l.song_id = s.song_id
)

-- Q9 [Hard]
-- Find users (username) who have listened to every song by artists
-- whose genre is 'Electronic'.
-- (Hint: double NOT EXISTS or NOT EXISTS + EXCEPT)
select u.username
from users u
where not exists (
    select s.song_id
    from songs s
    natural join artists a
    where a.genre = 'Electronic'
    except
    select l.song_id
    from listens l
    where l.user_id = u.user_id

)




-- Q10 [Hard]
-- Find users (username) who:
--   1. Have listened to songs in at least 3 different genres.
--   2. Have NEVER listened to any song longer than 400 seconds.
--   3. Have listened to at least one song in EVERY genre that
--      user_id = 1 has listened to.




-- Q11 [Hard]
-- For each country, find the artist_name of the artist whose songs
-- were listened to the most by users from that country.
-- (country, artist_name with the highest listen count for that country)


-- Q12 [Very Hard]
-- Find artist_name of all artists who:
--   1. Have released songs in at least 2 different release years.
--   2. Have had their songs listened to by ALL users whose
--      subscription_type is 'premium'.
--   3. Do NOT have any song with duration_seconds greater than the
--      longest song by the artist named 'The Weeknd'.


-- ============================================================
-- SECTION 3: ANSWERS
-- ============================================================


-- A1 [Easy]
-- Find the title and release_year of every song in the 'Pop' genre.

SELECT s.title, s.release_year
FROM songs s
JOIN artists a ON a.artist_id = s.artist_id
WHERE a.genre = 'Pop'


-- A2 [Easy]
-- Find the usernames of all users from 'Canada'. No duplicates.

SELECT DISTINCT username
FROM users
WHERE country = 'Canada'


-- A3 [Easy-Medium]
-- For each genre, count songs, ordered most to least.

SELECT a.genre, COUNT(s.song_id) AS song_count
FROM artists a
JOIN songs s ON s.artist_id = a.artist_id
GROUP BY a.genre
ORDER BY song_count DESC


-- A4 [Medium]
-- Find usernames of users who have listened to at least 10 distinct songs.

SELECT u.username
FROM users u
JOIN listens l ON l.user_id = u.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT l.song_id) >= 10


-- A5 [Medium]
-- Find songs listened to more than the average number of listens per song.

SELECT s.title
FROM songs s
NATURAL JOIN listens l
GROUP BY s.song_id, s.title
HAVING COUNT(*) > (
    SELECT AVG(listen_counts)
    FROM (
        SELECT COUNT(*) AS listen_counts
        FROM listens
        GROUP BY song_id
    ) AS counts
)


-- A6 [Medium]
-- For each playlist, show playlist_name and number of songs. Include playlists with zero songs.

SELECT pl.playlist_name, COUNT(ps.song_id) AS song_count
FROM playlists pl
LEFT JOIN playlist_songs ps ON ps.playlist_id = pl.playlist_id
GROUP BY pl.playlist_id, pl.playlist_name


-- A7 [Medium-Hard]
-- Find users who have listened to songs released in every year 2020-2024.

SELECT u.username
FROM users u
JOIN listens l ON l.user_id = u.user_id
JOIN songs s ON s.song_id = l.song_id
WHERE s.release_year BETWEEN 2020 AND 2024
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT s.release_year) = 5


-- A8 [Medium-Hard]
-- Find artists where every song they released has been listened to at least once.

-- Solution 1: NOT EXISTS
SELECT a.artist_name
FROM artists a
WHERE NOT EXISTS (
    SELECT 1
    FROM songs s
    WHERE s.artist_id = a.artist_id
    AND NOT EXISTS (
        SELECT 1
        FROM listens l
        WHERE l.song_id = s.song_id
    )
)

-- Solution 2: EXCEPT
SELECT a.artist_name
FROM artists a
WHERE NOT EXISTS (
    SELECT s.song_id
    FROM songs s
    WHERE s.artist_id = a.artist_id
    EXCEPT
    SELECT DISTINCT l.song_id
    FROM listens l
)


-- A9 [Hard]
-- Find users who have listened to every song by 'Electronic' artists.

-- Solution 1: double NOT EXISTS
SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM songs s
    JOIN artists a ON a.artist_id = s.artist_id
    WHERE a.genre = 'Electronic'
    AND NOT EXISTS (
        SELECT 1
        FROM listens l
        WHERE l.user_id = u.user_id
        AND l.song_id = s.song_id
    )
)

-- Solution 2: NOT EXISTS + EXCEPT
SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT s.song_id
    FROM songs s
    JOIN artists a ON a.artist_id = s.artist_id
    WHERE a.genre = 'Electronic'
    EXCEPT
    SELECT l.song_id
    FROM listens l
    WHERE l.user_id = u.user_id
)


-- A10 [Hard]
-- Users who:
--   1. Listened to songs in at least 3 different genres.
--   2. NEVER listened to any song longer than 400 seconds.
--   3. Listened to at least one song in EVERY genre that user_id = 1 has listened to.

SELECT u.username
FROM users u
WHERE u.user_id IN (
    SELECT l.user_id
    FROM listens l
    JOIN songs s ON s.song_id = l.song_id
    JOIN artists a ON a.artist_id = s.artist_id
    GROUP BY l.user_id
    HAVING COUNT(DISTINCT a.genre) >= 3
)
AND NOT EXISTS (
    SELECT 1
    FROM listens l2
    JOIN songs s2 ON s2.song_id = l2.song_id
    WHERE l2.user_id = u.user_id
    AND s2.duration_seconds > 400
)
AND NOT EXISTS (
    SELECT DISTINCT a3.genre
    FROM listens l3
    JOIN songs s3 ON s3.song_id = l3.song_id
    JOIN artists a3 ON a3.artist_id = s3.artist_id
    WHERE l3.user_id = 1
    EXCEPT
    SELECT DISTINCT a4.genre
    FROM listens l4
    JOIN songs s4 ON s4.song_id = l4.song_id
    JOIN artists a4 ON a4.artist_id = s4.artist_id
    WHERE l4.user_id = u.user_id
)


-- A11 [Hard]
-- For each country, find the artist whose songs were listened to most by users from that country.

SELECT t1.country, t1.artist_name
FROM (
    SELECT u.country, a.artist_name, COUNT(l.song_id) AS listen_count
    FROM users u
    JOIN listens l ON l.user_id = u.user_id
    JOIN songs s ON s.song_id = l.song_id
    JOIN artists a ON a.artist_id = s.artist_id
    GROUP BY u.country, a.artist_id, a.artist_name
) t1
WHERE t1.listen_count = (
    SELECT MAX(listen_count)
    FROM (
        SELECT u2.country, a2.artist_id, COUNT(l2.song_id) AS listen_count
        FROM users u2
        JOIN listens l2 ON l2.user_id = u2.user_id
        JOIN songs s2 ON s2.song_id = l2.song_id
        JOIN artists a2 ON a2.artist_id = s2.artist_id
        GROUP BY u2.country, a2.artist_id
    ) t2
    WHERE t2.country = t1.country
)


-- A12 [Very Hard]
-- Artists who:
--   1. Released songs in at least 2 different release years.
--   2. Had songs listened to by ALL premium users.
--   3. Have NO song longer than the longest song by 'The Weeknd'.

SELECT a.artist_name
FROM artists a
WHERE
    (
        SELECT COUNT(DISTINCT s1.release_year)
        FROM songs s1
        WHERE s1.artist_id = a.artist_id
    ) >= 2

    AND NOT EXISTS (
        SELECT u.user_id
        FROM users u
        WHERE u.subscription_type = 'premium'
        EXCEPT
        SELECT DISTINCT l.user_id
        FROM listens l
        JOIN songs s2 ON s2.song_id = l.song_id
        WHERE s2.artist_id = a.artist_id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM songs s3
        WHERE s3.artist_id = a.artist_id
        AND s3.duration_seconds > (
            SELECT MAX(s4.duration_seconds)
            FROM songs s4
            JOIN artists a4 ON a4.artist_id = s4.artist_id
            WHERE a4.artist_name = 'The Weeknd'
        )
    )
