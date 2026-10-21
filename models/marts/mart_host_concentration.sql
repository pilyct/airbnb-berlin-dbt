with stg as (
    select * from {{ ref('stg_listings') }}
),

by_band as (
    select district, host_size_band, count(*) as listings
    from stg
    group by 1, 2
),

shares_with_totals as (
    select
        district,
        host_size_band,
        listings,
        sum(listings) over (partition by district) as district_listings
    from by_band
)

select
    district,
    host_size_band,
    listings,
    district_listings,
    round(100.00 * listings / district_listings, 2) as share_of_district
from shares_with_totals
