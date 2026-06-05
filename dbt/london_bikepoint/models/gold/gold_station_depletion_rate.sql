with recent_history as (

    select *
    from public_silver.silver_bikepoint_status
    where snapshot_timestamp >= now() - interval '24 hours'

),

station_history as (

    select
        bikepoint_id,
        station_name,
        snapshot_timestamp,
        nb_bikes,

        first_value(nb_bikes) over (
            partition by bikepoint_id
            order by snapshot_timestamp
        ) as first_bikes,

        first_value(nb_bikes) over (
            partition by bikepoint_id
            order by snapshot_timestamp desc
        ) as last_bikes,

        min(snapshot_timestamp) over (
            partition by bikepoint_id
        ) as first_ts,

        max(snapshot_timestamp) over (
            partition by bikepoint_id
        ) as last_ts

    from recent_history

),

station_rates as (

    select distinct
        bikepoint_id,
        station_name,
        last_ts as snapshot_timestamp,
        first_bikes,
        last_bikes,

        extract(epoch from (last_ts - first_ts)) / 3600.0
            as hours_observed,

        (last_bikes - first_bikes)::numeric
            as bike_change

    from station_history

)

select
    bikepoint_id,
    station_name,
    snapshot_timestamp,
    first_bikes,
    last_bikes,
    round(hours_observed::numeric, 2) as hours_observed,
    round(bike_change, 2) as bike_change,

    abs(
        round(
            bike_change / nullif(hours_observed, 0),
            2
        )
    ) as bike_demand_per_hour

from station_rates
where hours_observed > 0
  and bike_change < 0