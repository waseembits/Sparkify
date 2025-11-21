create or replace table dim_users as
select distinct
    user_id,
    first_name,
    last_name,
    gender,
    level
from log_data_stg
where user_id is not null;


CREATE OR REPLACE TABLE dim_songs AS
SELECT DISTINCT
    song_id,
    title,
    artist_id,
    year,
    duration
FROM song_data_stg
WHERE song_id IS NOT NULL;


CREATE OR REPLACE TABLE dim_time AS
SELECT DISTINCT
    start_time,
    EXTRACT(hour FROM start_time)       AS hour,
    EXTRACT(day FROM start_time)        AS day,
    EXTRACT(week FROM start_time)       AS week,
    EXTRACT(month FROM start_time)      AS month,
    EXTRACT(year FROM start_time)       AS year,
    EXTRACT(weekday FROM start_time)    AS weekday
FROM log_data_stg
WHERE start_time IS NOT NULL;


CREATE OR REPLACE TABLE dim_artists AS
SELECT DISTINCT
    artist_id,
    artist_name,
    artist_location,
    artist_latitude,
    artist_longitude
FROM song_data_stg
WHERE artist_id IS NOT NULL;


CREATE OR REPLACE TABLE fact_songplays AS
SELECT
    UUID_STRING() AS songplay_id,  -- Unique ID for each play
    l.start_time AS start_time,            -- Timestamp from log data
    l.user_Id,
    l.level,
    s.song_id,
    s.artist_id,
    l.session_Id AS session_id,
    l.location,
    l.user_agent AS user_agent
FROM log_data_stg l
JOIN song_data_stg s
  ON l.song = s.title
  AND l.artist = s.artist_name;

  
select * from dim_users
limit 5;

select * from dim_songs 
limit 5;

select * from dim_time
limit 5;

select * from dim_artists
limit 5;

select * from fact_songplays
