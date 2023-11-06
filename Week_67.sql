CREATE SCHEMA WEEK_67;


CREATE OR REPLACE FUNCTION FF_WEEK_67_UDF (PAT_TYPE VARCHAR, APP_DATE DATE, PUB_DATE DATE)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
     TO_VARIANT(OBJECT_CONSTRUCT('days_difference',DATEDIFF(day,APP_DATE,PUB_DATE),
    'inside_of_projection',
    CASE WHEN (PAT_TYPE = 'Reissue' AND DATEDIFF(day,APP_DATE,PUB_DATE) >= 365) THEN  'true'
        WHEN (PAT_TYPE = 'Design' AND DATEDIFF(year,APP_DATE,PUB_DATE) >= 2) THEN 'true'
        ELSE 'false'
    END
    ))
$$;    

SELECT patent_index.patent_id
    , invention_title
    , patent_type
    , application_date 
    , document_publication_date
    , FF_WEEK_67_UDF (patent_type, application_date, document_publication_date) as object_as_output
    , object_as_output:inside_of_projection::VARCHAR as inside_of_projection
FROM cybersyn_us_patent_grants.cybersyn.uspto_contributor_index AS contributor_index
INNER JOIN
    cybersyn_us_patent_grants.cybersyn.uspto_patent_contributor_relationships AS relationships
    ON contributor_index.contributor_id = relationships.contributor_id
INNER JOIN
    cybersyn_us_patent_grants.cybersyn.uspto_patent_index AS patent_index
    ON relationships.patent_id = patent_index.patent_id
WHERE contributor_index.contributor_name ILIKE 'NVIDIA CORPORATION'
    AND relationships.contribution_type = 'Assignee - United States Company Or Corporation';
