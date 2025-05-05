-- 

WITH source_data as (
    SELECT 
        event_name,
        SAFE_CAST(event_timestamp as TIMESTAMP) as event_timestamp,
        SAFE_CAST(json_extract_scalar(payload, '$.countAttachment') AS INT64) as attachment_count,
        json_extract_scalar(payload, '$.eventUserType') as event_user_type,
        json_extract_scalar(payload, '$.eventVersion') as event_version,
        SAFE_CAST(json_extract_scalar(payload, '$.hasError') AS BOOL) as has_error,
        json_extract_scalar(payload, '$.messageId') as message_id,
        SAFE_CAST(json_extract_scalar(payload, '$.messageLength') AS INT64) as message_length,
        json_extract_scalar(payload, '$.messageType') as message_type,
        json_extract_scalar(payload, '$.organisationId') as organisation_id,
        json_extract_scalar(payload, '$.productOrigin') as product_origin,
        json_extract_scalar(payload, '$.sourceType') as source_type,
        json_extract_scalar(payload, '$.userId') as user_id
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

