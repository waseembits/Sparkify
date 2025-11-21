create DATABASE sparkify_wh;
use database sparkify_wh;

create or replace storage integration s3_integration_sparkify
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::017499099879:role/snowflake_role'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://sparkify-dwh-asjal/');

desc integration s3_integration_sparkify;

create or replace file format jsonformat type='JSON' strip_outer_array=true;

create or replace stage json_stage file_format = jsonformat;
drop stage json_stage;

-- SONG DATA STAGE
CREATE OR REPLACE STAGE sparkify_song_stage
STORAGE_INTEGRATION = s3_integration_sparkify
URL = 's3://sparkify-dwh-asjal/data/song_data/'
FILE_FORMAT = jsonformat;

-- LOG DATA STAGE
CREATE OR REPLACE STAGE sparkify_log_stage
STORAGE_INTEGRATION = s3_integration_sparkify
URL = 's3://sparkify-dwh-asjal/data/log_data/'
FILE_FORMAT = jsonformat;

LIST @sparkify_song_stage;
list @sparkify_log_stage;
