-- slowly changing dimension of user details by date/time

WITH user_src as (
    SELECT DISTINCT
        user_id,
        export_day,
        application_user_id,
        application_user_role,
        application_user_status,
        organisation_id,
        is_admin,
        created_at
    FROM {{ ref('src_user') }} 
),

scd as (
    SELECT
        *,
        SAFE_CAST(export_day as TIMESTAMP) as valid_from,
        COALESCE(
            TIMESTAMP_SUB(
            LEAD(SAFE_CAST(export_day as TIMESTAMP)) OVER(PARTITION BY user_id ORDER BY export_day ASC),
            INTERVAL 1 microsecond
            ),
            CAST('9999-12-31' AS TIMESTAMP)
        ) as valid_to
    FROM user_src
),

final as (
    SELECT 
        user_id,
        export_day,
        application_user_id,
        application_user_role,
        application_user_status,
        organisation_id,
        is_admin,
        created_at,
        valid_from,
        valid_to
    FROM scd
)

SELECT *
FROM final