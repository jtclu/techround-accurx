-- How many customers and users currently have access to a particular feature?

-- Assuming customer = organsation, each organisation may have 1 to multiple users but features can only be enabled/disabled for everyone belonging to the organisation
-- following aggregation is designed to enable users / BI dashboards to easily filter by date of interrogration

WITH daily_access_stat AS (
    SELECT 
        date_trunc(date_day, day) as date_day, 
        count(distinct organisation_id) as num_orgs,
        sum(selfbook_enabled_flag) as num_orgs_with_selfbook,
        sum(video_invite_enabled_flag) as num_orgs_with_video_invite,
        sum(sms_free_enabled_flag) as num_orgs_with_sms_free,
        sum(sms_paid_enabled_flag) as num_orgs_with_sms_paid
    FROM {{ ref('dim_org_feature_access_daily') }} 
    GROUP BY 1
    ORDER BY 1
)

SELECT *
FROM daily_access_stat
WHERE date_day = current_date 

-- for # of users, query can be customised with count(distinct user_id) 
-- using a CTE aggregating users per org from dim_user_detail
-- or we can surface a model similar to dim_org_feature_access_daily with user_id, subject to performance considerations 

