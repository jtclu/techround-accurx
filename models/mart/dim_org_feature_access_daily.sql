-- time series flag table indicating if an org has access to each feature on a given date

WITH datespine AS (
    SELECT 
        SAFE_CAST(date_day AS DATE) AS date_day
    FROM {{ ref('dim_date_spine') }}
),

self_book AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_self_book_individual') }}
    WHERE has_self_book_enabled IS TRUE
),

video_invite AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_video') }}
    WHERE has_video_enabled IS TRUE
),

sms_free AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_sms') }}
    WHERE sms_feature = 'SMS Lite'
),

sms_paid AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_sms') }}
    WHERE sms_feature = 'SMS Plus'
),


-- on any given day, which orgs have which features enabled?

daily_feature_access_by_org as ( -- will want to export_day range add data testing in src to code defensively
    SELECT
        datespine.date_day,
        self_book.organisation_id,
        CASE
            WHEN self_book.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS selfbook_enabled_flag,
        CASE
            WHEN video_invite.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS videoinvite_enabled_flag,
        CASE
            WHEN sms_free.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS sms_free_enabled_flag,
        CASE
            WHEN sms_paid.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS sms_paid_enabled_flag
    FROM datespine
    LEFT JOIN self_book
        ON self_book.valid_from >= datespine.date_day
        AND self_book.valid_to < datespine.date_day
    LEFT JOIN video_invite
        ON video_invite.valid_from >= datespine.date_day
        AND video_invite.valid_to < datespine.date_day
    LEFT JOIN sms_free
        ON sms_free.valid_from >= datespine.date_day
        AND sms_free.valid_to < datespine.date_day
    LEFT JOIN sms_paid
        ON sms_paid.valid_from >= datespine.date_day
        AND sms_paid.valid_to < datespine.date_day
),

final as (
    SELECT
        date_day,
        organisation_id,
        selfbook_enabled_flag,
        videoinvite_enabled_flag,
        sms_free_enabled_flag,
        sms_paid_enabled_flag
    FROM daily_feature_access_by_org
)

select *
from final