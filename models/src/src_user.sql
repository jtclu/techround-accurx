-- 

WITH source_data as (
    SELECT
        SAFE_CAST(export_day as DATE) as export_day,
        filename,
        SAFE_CAST(file_row_no as INT64) as file_row_no,
        SAFE_CAST(file_loaded_day as DATE) as file_loaded_day,
        json_extract_scalar(payload, '$.applicationUserId') as application_user_id,
        SAFE_CAST(json_extract_scalar(payload, '$.createdAt') as TIMESTAMP) as created_at,
        SAFE_CAST(json_extract_scalar(payload, '$.isAdmin') as BOOL) as is_admin,
        json_extract_scalar(payload, '$.organisationId') as organisation_id,
        json_extract_scalar(payload, '$.role') as application_user_role,
        json_extract_scalar(payload, '$.status') as application_user_status,
        json_extract_scalar(payload, '$.userId') as user_id
    FROM {{ source('raw_mock_data', 'user') }}
),

-- following step assumes raw data may have multiple uploads of the same file due to to pipeline re-uploads, deduplication allows for conflict-handling
-- it does not assume the combination of each export_day and filename has newly created application users only, that deduping is done in the staging layer as that has more to do with analytical logic than pipeline orchestration
-- these are already the case for the mock data, but this is a good practice to have in place

deduped as (
    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER(PARTITION BY export_day, filename, file_row_no ORDER BY file_loaded_day DESC) = 1
)

SELECT
    application_user_id,
    created_at,
    is_admin,
    organisation_id,
    application_user_role,
    application_user_status,
    user_id,
    export_day,
    filename,
    file_row_no,
    file_loaded_day
FROM deduped

