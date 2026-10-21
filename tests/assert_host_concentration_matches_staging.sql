with mart as (
    select coalesce(sum(listings), 0) as mart_listings
    from {{ ref('mart_host_concentration') }}
),

stg as (
    select count(*) as stg_listings
    from {{ ref('stg_listings') }}
)

select
    mart_listings,
    stg_listings
from mart
cross join stg
where mart_listings <> stg_listings