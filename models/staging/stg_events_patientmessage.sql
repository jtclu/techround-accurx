-- split event stream by name of the event to make it easier to analyse product interactions

WITH messaging_events as (
    SELECT
        user_id,
        organisation_id,
        event_timestamp,
        event_user_type,
        event_version,
        source_type AS event_client, -- app or web
        product_origin,
        message_id,
        message_type,
        message_length,
        attachment_count,
        has_error
    FROM {{ ref('src_event') }}
    WHERE event_name = 'PatientMessage Create Server'
)

SELECT *
FROM messaging_events

