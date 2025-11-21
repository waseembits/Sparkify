select * from raw_song_data
limit 1;
select * from raw_log_data
limit 50;

-- create a clean, deduped staging table for songs
CREATE OR REPLACE TABLE song_data_stg AS
SELECT
  song_id,
  title,
  artist_id,
  artist_name,
  artist_location,
  artist_latitude,
  artist_longitude,
  duration,
  year
FROM (
  SELECT
    data:song_id::STRING                                 AS song_id,
    TRIM(data:title::STRING)                             AS title,
    data:artist_id::STRING                               AS artist_id,
    TRIM(data:artist_name::STRING)                       AS artist_name,
    TRIM(data:artist_location::STRING)                   AS artist_location,
    data:artist_latitude::FLOAT                          AS artist_latitude,
    data:artist_longitude::FLOAT                         AS artist_longitude,
    data:duration::FLOAT                                 AS duration,
    data:year::INT                                       AS year,
    ROW_NUMBER() OVER (PARTITION BY data:song_id::STRING
                       ORDER BY COALESCE(data:year::INT, 0) DESC,
                                COALESCE(data:duration::FLOAT, 0) DESC) AS rn
  FROM raw_song_data
  WHERE data:song_id IS NOT NULL
)
WHERE rn = 1;


-- basic counts
SELECT COUNT(*) AS total_songs FROM song_data_stg;

-- sample rows
SELECT * FROM song_data_stg;

-- check for leftover duplicates (should return zero rows)
SELECT song_id, COUNT(*) cnt
FROM song_data_stg
GROUP BY song_id
HAVING COUNT(*) > 1;

-- check for null critical ids (should be zero due to WHERE clause)
SELECT COUNT(*) FROM song_data_stg WHERE song_id IS NULL OR artist_id IS NULL;



CREATE OR REPLACE TABLE log_data_stg AS
SELECT DISTINCT
    data:userId::INT AS user_id,
    TRIM(data:firstName::STRING) AS first_name,
    TRIM(data:lastName::STRING) AS last_name,
    data:gender::STRING AS gender,
    data:level::STRING AS level,
    data:artist::STRING AS artist,
    data:song::STRING AS song,
    data:length::FLOAT AS length,
    data:sessionId::INT AS session_id,
    data:location::STRING AS location,
    data:userAgent::STRING AS user_agent,
    data:ts::NUMBER AS ts,
    TO_TIMESTAMP_LTZ(data:ts::NUMBER / 1000) AS start_time
FROM raw_log_data
WHERE data:page::STRING = 'NextSong'
  AND data:userId IS NOT NULL;



-- check data
SELECT * FROM log_data_stg LIMIT;

-- verify timestamp conversion
SELECT user_id, start_time, ts FROM log_data_stg LIMIT 5;

-- check total count of song play events
SELECT COUNT(*) FROM log_data_stg;

-- confirm no null user_ids
SELECT COUNT(*) FROM log_data_stg WHERE user_id IS NULL;



-- checking if the data actually matches or not
SELECT
    *
FROM log_data_stg l
JOIN song_data_stg s
  ON l.song = s.title
  and l.artist = s.artist_name;
