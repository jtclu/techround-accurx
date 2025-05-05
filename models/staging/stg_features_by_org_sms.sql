-- which orgs have SMS features enabled and when

WITH sms_records as (
    SELECT *
    FROM {{ ref('src_feature') }}
    WHERE feature_name = 'SMS'
),

org_flags_by_export as (
    SELECT
        organisation_id,
        export_day,
        feature_selected AS sms_feature, -- 'SMS Lite' is free tier 'SMS Plus' is paid -- sample data currently only shows Lite
        CASE
            WHEN feature_selected = 'SMS Lite' THEN 'Free'
            WHEN feature_selected = 'SMS Plus' THEN 'Paid'
            ELSE NULL
        END AS product_tier
    FROM sms_records
),

final as (
    SELECT
        organisation_id,
        sms_feature,
        product_tier,
        export_day as valid_from,
        COALESCE(
            LEAD(export_day) OVER(PARTITION BY organisation_id ORDER BY export_day),
            '9999-12-31'
        )AS valid_to
    FROM org_flags_by_export
)

SELECT *
FROM final

