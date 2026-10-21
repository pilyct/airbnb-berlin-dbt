select
    district,
    host_size_band,
    count(*) as n_rows
from {{ ref('mart_host_concentration') }}
group by 1, 2
having count(*) > 1