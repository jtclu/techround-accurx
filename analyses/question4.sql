-- They have identified a customer who has used a feature that they don’t pay for. 
-- How often does this happen and why?

-- monitor events happening in the paid feature from users who don't have paid access enabled

SELECT
    usage.event_timestamp,
    usage.user_id,
    usage.org_id,
    access.sms_free_enabled_flag,
    access.sms_paid_enabled_flag
FROM {{ ref('fact_usage_patientmessage') }} AS usage
LEFT JOIN {{ ref('dim_org_feature_access_daily') }} AS access
    ON usage.org_id = access.org_id
    AND DATE(usage.event_timestamp) = access.date_day
WHERE access.sms_free_enabled_flag != 1
AND usage.product_origin = 'SimpleMessage' -- insert correct value here for paid product
