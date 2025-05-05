-- split event stream by name of the event to make it easier to analyse product interactions

WITH video_events as (
    SELECT
        user_id,
        organisation_id,
        event_timestamp,
        event_user_type,
        source_type AS event_client,
        message_id,
        message_type,
        product_origin,
        has_error
    FROM {{ ref('src_event') }}
    WHERE event_name = 'PatientVideoInvite Create Server'
)

SELECT *
FROM video_events

