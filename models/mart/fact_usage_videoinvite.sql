-- fact usage table consisting of one row per video invite event

WITH video_invites as (
    SELECT
        message_id AS event_id,
        *
    FROM {{ ref('stg_events_videoinvite') }}
),

final as (
    SELECT 
        event_id,
        event_timestamp,
        user_id,
        organisation_id,
        event_user_type,
        product_origin,
        message_type,
        event_client,
        has_error
    FROM video_invites
)

SELECT *
FROM final
