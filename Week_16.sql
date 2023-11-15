use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_16;
use schema week_16;


create or replace file format json_ff
    type = json
    strip_outer_array = TRUE;
    
create or replace stage week_16_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_16/'
    file_format = json_ff;

create or replace table week_16.week16 as
select t.$1:word::text word, t.$1:url::text url, t.$1:definition::variant definition  
from @week_16_frosty_stage (file_format => 'json_ff', pattern=>'.*week16.*') t;

truncate week16;
select parse_json(definition):meanings from week16;

select 
    word,
    url,
    definition,
    meanings.value:"partOfSpeech"::STRING as part_of_speech,
    meanings.value:"synonyms"::STRING as general_synonyms,
    meanings.value:"antonyms"::STRING as general_antonyms,
    --meanings.value::STRING,
    definitions.value:"definition"::STRING as defintion,
    definitions.value:"example"::STRING as example_if_applicable,
    definitions.value:"synonyms"::STRING as definitional_synonyms,
    definitions.value:"antonyms"::STRING as definitional_antonyms
from week16,
LATERAL FLATTEN(definition, outer => TRUE, mode => 'ARRAY') types,
LATERAL FLATTEN(types.value:meanings) meanings,
LATERAL FLATTEN(meanings.value:definitions) definitions;

select count (distinct word) from week16;

select 
    *
    --count (word)
    --count(distinct word)
from (
    select 
        word,
        url,
        definition,
        meanings.value:"partOfSpeech"::STRING as part_of_speech,
        meanings.value:"synonyms"::STRING as general_synonyms,
        meanings.value:"antonyms"::STRING as general_antonyms,
        definitions.value:"definition"::STRING as defintion,
        definitions.value:"example"::STRING as example_if_applicable,
        definitions.value:"synonyms"::STRING as definitional_synonyms,
        definitions.value:"antonyms"::STRING as definitional_antonyms
    from week16,
    LATERAL FLATTEN(definition, outer => TRUE, mode => 'ARRAY') types,
    LATERAL FLATTEN(types.value:meanings, outer => TRUE, mode => 'ARRAY') meanings,
    LATERAL FLATTEN(meanings.value:definitions, outer => TRUE, mode => 'ARRAY') definitions
) sub
--where word like 'l%'
;
