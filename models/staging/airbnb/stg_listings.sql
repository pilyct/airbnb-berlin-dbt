select
        id::bigint as listing_id,
        host_id::bigint as host_id,
        calculated_host_listings_count::int as host_listing_count,
        neighbourhood_group_cleansed as district,

        case 
            when calculated_host_listings_count::int = 1 then '1'
            when calculated_host_listings_count::int <= 4 then '2-4'
            when calculated_host_listings_count::int <= 9 then '5-9'
            else '10+'
        end as host_size_band,

        case
            when license is null or trim(license) = '' then 'missing'
            when license ilike 'exempt%' then 'exempt'
            -- Berlin registration number, e.g. 04/Z/AZ/020562-26
            -- ^ and $ anchor the whole value; 'i' makes it case-insensitive.
            -- All-digit placeholders such as 12/3/45/678910-11 fail the letter slots and stay in 'other',
            -- and so do typos such as 01-Z-NA-OO4O70-15.
            when regexp_matches(trim(license), '^[0-9]{2}/[A-Z]/[A-Z]{2}/[0-9]{6}-[0-9]{2}$', 'i') then 'registration number'
            when license ilike 'legal entity name%' then 'legal entity'
            when license ilike 'first name and last name%' then 'private individual'
            else 'other'
        end as license_type

from {{ source('airbnb', 'listings') }}