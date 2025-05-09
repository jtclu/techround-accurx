-- time series flag table indicating if an org has access to each feature on a given date

WITH datespine AS (
    SELECT 
        SAFE_CAST(date_day AS DATE) AS date_day,
        is_week_start,
        is_month_start
    FROM {{ ref('dim_date_spine') }}
),

organisations_daiy AS ( -- lists all organisations that existed in the landscape on a given day regardless of feature onboarding
    SELECT DISTINCT
        organisation_id,
        export_day
    FROM {{ ref('src_feature') }}    
),

daily_data_frame AS (
    SELECT 
        datespine.*,
        organisations_daiy.organisation_id
    FROM datespine
    LEFT JOIN organisations_daiy
        ON datespine.date_day = organisations_daiy.export_day
),

-- duo-step CTEs to insert each feature flag into the daily_data_frame; allows for modularity and performance optimisation

self_book AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_self_book_individual') }}
    WHERE has_self_book_enabled IS TRUE
),
add_selfbook_flag AS (
    SELECT 
        daily_data_frame.*,
        CASE
            WHEN self_book.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS selfbook_enabled_flag,
    FROM daily_data_frame
    LEFT JOIN self_book
        ON daily_data_frame.organisation_id = self_book.organisation_id
        AND daily_data_frame.date_day >= self_book.valid_from
        AND daily_data_frame.date_day < self_book.valid_to
),

video_invite AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_video') }}
    WHERE has_video_enabled IS TRUE
),
add_videoinvite_flag AS (
    SELECT 
        add_selfbook_flag.*,
        CASE
            WHEN video_invite.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS video_invite_enabled_flag
    FROM add_selfbook_flag
    LEFT JOIN video_invite
        ON add_selfbook_flag.organisation_id = video_invite.organisation_id
        AND add_selfbook_flag.date_day >= video_invite.valid_from
        AND add_selfbook_flag.date_day < video_invite.valid_to
),

sms_free AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_sms') }}
    WHERE sms_feature = 'SMS Lite'
),
add_smsfree_flag AS (
    SELECT 
        add_videoinvite_flag.*,
        CASE
            WHEN sms_free.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS sms_free_enabled_flag
    FROM add_videoinvite_flag
    LEFT JOIN sms_free
        ON add_videoinvite_flag.organisation_id = sms_free.organisation_id
        AND add_videoinvite_flag.date_day >= sms_free.valid_from
        AND add_videoinvite_flag.date_day < sms_free.valid_to
),

sms_paid AS (
    SELECT 
        organisation_id,
        valid_from,
        valid_to
    FROM {{ ref('stg_features_by_org_sms') }}
    WHERE sms_feature = 'SMS Plus'
),
add_smspaid_flag AS (
    SELECT 
        add_smsfree_flag.*,
        CASE
            WHEN sms_paid.organisation_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS sms_paid_enabled_flag
    FROM add_smsfree_flag
    LEFT JOIN sms_paid
        ON add_smsfree_flag.organisation_id = sms_paid.organisation_id
        AND add_smsfree_flag.date_day >= sms_paid.valid_from
        AND add_smsfree_flag.date_day < sms_paid.valid_to
),

final as (
    SELECT
        date_day,
        organisation_id,
        selfbook_enabled_flag,
        video_invite_enabled_flag,
        sms_free_enabled_flag,
        sms_paid_enabled_flag,
        is_week_start,
        is_month_start
    FROM add_smspaid_flag
)

select *
from final