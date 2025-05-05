-- which orgs have SMS features enabled and when

WITH individual_records as (
    SELECT *
    FROM {{ ref('src_feature') }}
    WHERE feature_name = 'Self Book Individual'
),

org_flags_by_export as (
    SELECT
        organisation_id,
        export_day,
        CASE
            WHEN feature_selected = 'On' THEN True
            WHEN feature_selected = 'Off' THEN False 
            ELSE NULL
        END AS has_self_book_enabled
    FROM individual_records
),

final as (
    SELECT
        organisation_id,
        has_self_book_enabled,
        export_day as valid_from,
        COALESCE(
            LEAD(export_day) OVER(PARTITION BY organisation_id ORDER BY export_day),
            '9999-12-31'
        )AS valid_to
    FROM org_flags_by_export
)

SELECT *
FROM final
