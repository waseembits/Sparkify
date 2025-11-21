create or replace table raw_song_data (
    data VARIANT 
);

copy into raw_song_data
from @sparkify_song_stage
file_format = (type = json) 
ON_ERROR = 'CONTINUE';

select *
from raw_song_data
limit 5;

CREATE OR REPLACE TABLE raw_log_data (
    data variant
);
truncate table raw_log_data;

copy into raw_log_data
from @sparkify_log_stage
file_format = (type = json) 
ON_ERROR = 'CONTINUE';

select *
from raw_song_data;
select *
from raw_log_data;