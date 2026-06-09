-- ============================================================
-- SECTION 1: SQL MODIFICATION PATTERNS REFERENCE
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


-- PATTERN 1: CREATE TABLE with primary key and data types
-- Create the users table from scratch.

CREATE TABLE users (
    user_id     INT,
    username    VARCHAR(50),
    country     VARCHAR(50),
    subscription_type VARCHAR(20),
    PRIMARY KEY (user_id)
);


-- PATTERN 2: CREATE TABLE with a foreign key
-- Create the songs table, referencing artists.

CREATE TABLE songs (
    song_id          INT,
    title            VARCHAR(100),
    artist_id        INT,
    duration_seconds INT,
    release_year     INT,
    PRIMARY KEY (song_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);


-- PATTERN 3: CREATE TABLE with a composite primary key and multiple foreign keys
-- (standard pattern for many-to-many bridge tables)

CREATE TABLE playlist_songs (
    playlist_id INT,
    song_id     INT,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);


-- PATTERN 4: INSERT with explicit VALUES
-- Add a new user.

INSERT INTO users (user_id, username, country, subscription_type)
VALUES (101, 'andrewh', 'USA', 'premium');


-- PATTERN 5: INSERT multiple rows at once

INSERT INTO users (user_id, username, country, subscription_type)
VALUES
    (102, 'janesmith', 'Canada', 'free'),
    (103, 'carlos99', 'Mexico', 'premium');


-- PATTERN 6: INSERT using a SELECT (bulk insert from another table or query)
-- Enroll every 'free' user into a default playlist with playlist_id = 1.
-- (Add a row to playlist_songs for each free user's most recent listen)

INSERT INTO playlist_songs (playlist_id, song_id)
SELECT 1, l.song_id
FROM listens l
JOIN users u ON u.user_id = l.user_id
WHERE u.subscription_type = 'free';


-- PATTERN 7: UPDATE a single column with a fixed value
-- Change user_id 101's subscription to 'free'.

UPDATE users
SET subscription_type = 'free'
WHERE user_id = 101;


-- PATTERN 8: UPDATE using an expression (e.g. multiply, concatenate)
-- Give every song released before 2010 an extra 30 seconds of duration.

UPDATE songs
SET duration_seconds = duration_seconds + 30
WHERE release_year < 2010;


-- PATTERN 9: UPDATE using a scalar subquery in SET
-- Set every song's duration to the average duration of all songs by that artist.

UPDATE songs s
SET duration_seconds = (
    SELECT AVG(s2.duration_seconds)
    FROM songs s2
    WHERE s2.artist_id = s.artist_id
);


-- PATTERN 10: UPDATE with a subquery in WHERE (IN)
-- Upgrade all users from 'Canada' who have listened to more than 50 songs to 'premium'.

UPDATE users
SET subscription_type = 'premium'
WHERE country = 'Canada'
AND user_id IN (
    SELECT user_id
    FROM listens
    GROUP BY user_id
    HAVING COUNT(DISTINCT song_id) > 50
);


-- PATTERN 11: DELETE with a simple WHERE condition

DELETE FROM listens
WHERE listen_date < '2020-01-01';


-- PATTERN 12: DELETE with a subquery in WHERE (IN)
-- Delete all listens for songs by artists in the 'Country' genre.

DELETE FROM listens
WHERE song_id IN (
    SELECT s.song_id
    FROM songs s
    JOIN artists a ON a.artist_id = s.artist_id
    WHERE a.genre = 'Country'
);


-- PATTERN 13: DELETE with a correlated subquery (NOT IN / NOT EXISTS)
-- Delete all users who have never listened to any song.

DELETE FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id FROM listens
);


-- PATTERN 14: LIKE for pattern matching (case sensitive)
-- Delete all listens for songs whose title contains the word 'remix'.

DELETE FROM listens
WHERE song_id IN (
    SELECT song_id FROM songs WHERE title LIKE '%remix%'
);

-- Case-insensitive version using LOWER():
DELETE FROM listens
WHERE song_id IN (
    SELECT song_id FROM songs WHERE LOWER(title) LIKE '%remix%'
);


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


-- Q1 [Easy - DDL]
-- Write the CREATE TABLE statement for the listens table.
-- It should have: user_id, song_id, listen_date (a date), duration_played (an integer).
-- The primary key is (user_id, song_id, listen_date).
-- user_id references users, song_id references songs.

create table listens (
    user_id int,
    song_id int,
    listen_date date,
    during_played int,
    primary key (user_id, song_id, listen_date),
    foreign key song_id references songs(song_id),
    foreign_key user_id references users(user_id)

)

-- Q2 [Easy - INSERT]
-- Insert a new artist: artist_id = 50, artist_name = 'Daft Punk', genre = 'Electronic'.

insert into artists (artist_id, artist_name, genre)
values (50, 'Daft Punk', 'Electronic');


-- Q3 [Easy - UPDATE]
-- Change the genre of all artists named 'Daft Punk' to 'Dance'.
update artists
set genre = 'Dance'
where artist_name = 'Daft Punk'


-- Q4 [Easy - DELETE]
-- Delete all songs released before the year 2000.

delete from songs
where release_year < 2000;


-- Q5 [Medium - INSERT with SELECT]
-- Every user with subscription_type = 'premium' should be given their own playlist.
-- Insert into playlists one row per premium user, using their user_id,
-- playlist_name = 'My Playlist', and created_date = '2025-01-01'.
-- Assume playlist_id can be auto-generated (or use user_id as playlist_id for simplicity).

insert into playlists
select user_id, user_id, 'My Playlist', '2025-01-01'
from users
where subscription_type = 'premium';


-- Q6 [Medium - UPDATE with subquery]
-- Give a 10% raise to... wait wrong class.
-- Update every song's release_year to 2024 if that song has never been listened to.

update songs
set release_year = 2024
where song_id not in (
    select distinct song_id from listens
)


-- Q7 [Medium - DELETE with subquery]
-- Delete all playlists that contain no songs.
-- (Hint: use NOT IN or NOT EXISTS against playlist_songs)

delete from playlists
where playlist_id not exists (
    select 1
    from playlist_songs
    
)

-- Q8 [Medium - DELETE with LIKE]
-- Delete all songs whose title contains the word 'live' (case-insensitive).


-- Q9 [Hard - UPDATE with correlated subquery]
-- For each user, update their subscription_type to 'premium' if the total
-- duration_played across all their listens is greater than the average
-- total duration_played across all users.


-- Q10 [Hard - chained modifications]
-- A new song is being added and immediately enrolled into a playlist:
-- a) Insert song: song_id=999, title='New Song', artist_id=1, duration_seconds=200, release_year=2025.
-- b) Insert into playlist_songs: add song 999 to every playlist owned by user_id = 5.


-- ============================================================
-- SECTION 3: ANSWERS
-- ============================================================


-- A1 [Easy - DDL]

CREATE TABLE listens (
    user_id         INT,
    song_id         INT,
    listen_date     DATE,
    duration_played INT,
    PRIMARY KEY (user_id, song_id, listen_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);


-- A2 [Easy - INSERT]

INSERT INTO artists (artist_id, artist_name, genre)
VALUES (50, 'Daft Punk', 'Electronic');


-- A3 [Easy - UPDATE]

UPDATE artists
SET genre = 'Dance'
WHERE artist_name = 'Daft Punk';


-- A4 [Easy - DELETE]

DELETE FROM songs
WHERE release_year < 2000;


-- A5 [Medium - INSERT with SELECT]

INSERT INTO playlists (playlist_id, user_id, playlist_name, created_date)
SELECT user_id, user_id, 'My Playlist', '2025-01-01'
FROM users
WHERE subscription_type = 'premium';


-- A6 [Medium - UPDATE with subquery]

UPDATE songs
SET release_year = 2024
WHERE song_id NOT IN (
    SELECT DISTINCT song_id FROM listens
);


-- A7 [Medium - DELETE with subquery]

-- Solution 1: NOT IN
DELETE FROM playlists
WHERE playlist_id NOT IN (
    SELECT DISTINCT playlist_id FROM playlist_songs
);

-- Solution 2: NOT EXISTS
DELETE FROM playlists
WHERE NOT EXISTS (
    SELECT 1
    FROM playlist_songs ps
    WHERE ps.playlist_id = playlists.playlist_id
);


-- A8 [Medium - DELETE with LIKE]

DELETE FROM songs
WHERE LOWER(title) LIKE '%live%';


-- A9 [Hard - UPDATE with correlated subquery]

UPDATE users u
SET subscription_type = 'premium'
WHERE (
    SELECT SUM(l.duration_played)
    FROM listens l
    WHERE l.user_id = u.user_id
) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(duration_played) AS total
        FROM listens
        GROUP BY user_id
    ) AS user_totals
);


-- A10 [Hard - chained modifications]

-- a) Insert the new song
INSERT INTO songs (song_id, title, artist_id, duration_seconds, release_year)
VALUES (999, 'New Song', 1, 200, 2025);

-- b) Add it to every playlist owned by user_id = 5
INSERT INTO playlist_songs (playlist_id, song_id)
SELECT pl.playlist_id, 999
FROM playlists pl
WHERE pl.user_id = 5;
