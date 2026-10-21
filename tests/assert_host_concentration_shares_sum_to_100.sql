select
    district,
    sum(share_of_district) as total_share
from {{ ref('mart_host_concentration') }}
group by 1
-- condition: the sum is more than 0.05 away from 100
having abs(sum(share_of_district) - 100) > 0.05
