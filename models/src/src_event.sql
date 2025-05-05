-- 

WITH source_data as (
    SELECT 
        event_name,
        SAFE_CAST(event_timestamp as TIMESTAMP) as event_timestamp,
        SAFE_CAST(json_extract_scalar(payload, '$.countAttachment') AS INT64) as attachment_count,
        COALESCE(
            json_extract_scalar(payload, '$.eventUserType'),
            json_extract_scalar(payload, '$.Usertype')
        ) as event_user_type,
        json_extract_scalar(payload, '$.eventVersion') as event_version,
        COALESCE(
            SAFE_CAST(json_extract_scalar(payload, '$.hasError') AS BOOL),
            SAFE_CAST(json_extract_scalar(payload, '$.WithError') AS BOOL)
        ) as has_error,
        COALESCE(
            json_extract_scalar(payload, '$.messageId'), 
            json_extract_scalar(payload, '$.Id') 
        ) as message_id,
        COALESCE(
            SAFE_CAST(json_extract_scalar(payload, '$.messageLength') AS INT64),
            SAFE_CAST(json_extract_scalar(payload, '$.Messagelength') AS INT64)
        ) as message_length,
        COALESCE(
            json_extract_scalar(payload, '$.messageType'), 
            json_extract_scalar(payload, '$.Type') 
        ) as message_type,
        COALESCE(
            json_extract_scalar(payload, '$.organisationId'), 
            json_extract_scalar(payload, '$.OrganisationID') 
        ) as organisation_id,
        json_extract_scalar(payload, '$.productOrigin') as product_origin,
        COALESCE(
            json_extract_scalar(payload, '$.sourceType'), 
            json_extract_scalar(payload, '$.SourceType')
        ) as source_type,
        COALESCE(
            json_extract_scalar(payload, '$.userId'),
            json_extract_scalar(payload, '$.UserID')
        ) as user_id
    FROM {{ source('raw_mock_data', 'event')}}
)

SELECT
    event_name,
    event_timestamp,
    attachment_count,
    event_user_type,
    event_version,
    has_error,
    message_id,
    message_length,
    message_type,
    organisation_id,
    product_origin,
    source_type,
    user_id
FROM source_data

