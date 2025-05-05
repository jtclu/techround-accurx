-- fact usage table consisting of one row per patient messaging event

WITH patient_messages as (
    SELECT
        message_id as event_id,
        *
    FROM {{ ref('stg_events_patientmessage') }}
),

final as (
    SELECT 
        event_id,
        event_timestamp,
        user_id,
        organisation_id,
        event_user_type,
        event_version,
        event_client,
        product_origin,
        message_type,
        has_error
    FROM patient_messages
)

SELECT *
FROM final
