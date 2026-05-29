with ranked as (
    select
        *,
        row_number() over (
            partition by bikepoint_id
            order by snapshot_timestamp desc
        ) as rn
    from "bikepoint"."public_silver"."silver_bikepoint_status"
),

latest as (
    select
        bikepoint_id,
        station_name,
        snapshot_timestamp,
        latitude,
        longitude,
        nb_bikes,
        nb_docks,
        nb_spaces,
        nb_empty_docks,
        nb_standard_bikes,
        nb_ebikes,

        case
            when nb_spaces > 0 then round((nb_bikes::numeric / nb_spaces) * 100, 2)
            else null
        end as utilization_percent,

        case
            when nb_bikes < 3 then true
            else false
        end as is_high_risk

    from ranked
    where rn = 1
)

select *
from latest