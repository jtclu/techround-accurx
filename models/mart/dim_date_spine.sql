WITH date_spine_day as ( -- generates a serie of dates from min(export_date) in the source table (or lookback window if optimisation is needed) to specified future date
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-03-01' as date)",
        end_date="cast('2034-03-01' as date)" 
    )
    }}
), 

date_spine_month as (
    {{ dbt_utils.date_spine(
        datepart="month",
        start_date="cast('2024-03-01' as date)",
        end_date="cast('2034-03-01' as date)" 
    )
    }}
),

date_spine_week as (
    {{ dbt_utils.date_spine(
        datepart="week",
        start_date="cast('2024-03-01' as date)",
        end_date="cast('2034-03-01' as date)" 
    )
    }}
)

SELECT 
    date_day AS date_day,
    CASE WHEN date_spine_month IS NOT NULL THEN TRUE ELSE FALSE END AS is_month_start,
    CASE WHEN date_spine_week IS NOT NULL THEN TRUE ELSE FALSE END AS is_week_start
FROM date_spine_day
LEFT JOIN date_spine_month 
    ON date_spine_day.date_day = date_spine_month.date_month
LEFT JOIN date_spine_week
    ON date_spine_day.date_day = date_spine_week.date_week

