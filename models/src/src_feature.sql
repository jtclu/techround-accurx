with source_data as (
  SELECT 
    SAFE_CAST(export_day as DATE) as export_day,
    filename as filename,
    SAFE_CAST(file_row_no as INT64) as file_row_no,
    SAFE_CAST(file_loaded_day as DATE) as file_loaded_day,
    json_extract_scalar(payload, '$.organisationId') as organisation_id,
    json_extract_array(payload, '$.features') as feature,
  FROM `tech-round-accurx.raw_mock_data.feature` 
),

-- following step assumes raw data may have multiple uploads of the same file due to to pipeline re-uploads, deduplication allows for conflict-handling
-- it does not assume the combination of each export_day and filename has newly created application users only, that deduping is done in the staging layer as that has more to do with analytical logic than pipeline orchestration
-- these are already the case for the mock data, but this is a good practice to have in place

source_deduped as (
    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER(PARTITION BY export_day, filename, file_row_no ORDER BY file_loaded_day DESC) = 1
),

source_flattened as (
  SELECT
    * EXCEPT(feature),
    json_extract_scalar(f, '$.Name') as feature_name,
    json_extract(f, '$.Options') as features_available,
    json_extract_scalar(f, '$.SelectedOption') as feature_selected
  FROM source_deduped
  INNER JOIN unnest(source_deduped.feature) as f
),

final as (
  SELECT 
    feature_name,
    features_available,
    feature_selected,
    organisation_id,
    export_day,
    filename,
    file_row_no,
    file_loaded_day
  FROM source_flattened
)

select *
from final
