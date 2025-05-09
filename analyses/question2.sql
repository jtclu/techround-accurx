-- two possible approaches

-- 1. augment the existing {{ dim_user_detail }} model with a new column for each feature
-- then look up feature access flags from {{ dim_org_feature_access_daily }} using organisation_id and date joins
-- 'is_week_start column' is designed to enable users to filter by week rather than day

-- 2. we literally build the same model as {{ ref('dim_org_feature_access_daily') }} into the mart 
-- with user_id instead of organisation_id
-- it would involve lookup in step 1 but actually materialise the result instead of assuming stakeholders will self-perform a join for lookup