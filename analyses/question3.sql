-- let's see for example which org uses patient messaging the most in a given month

SELECT 
  date_trunc(event_timestamp, month) as mth, 
  organisation_id,
  count(distinct event_id) as num_patient_messaging_events
FROM {{ ref('fact_usage_patientmessage') }}  
GROUP BY 1, 2
HAVING count(distinct event_id) >= 1
ORDER BY 1, 2

-- the mart table is designed to enable aggregations like this very easily. 
-- the 'FROM' table can simply be replaced with fact_usage_videoinvite to answer the same question for the video feature
