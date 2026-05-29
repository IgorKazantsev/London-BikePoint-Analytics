with raw as (
    select
        id as raw_id,
        snapshot_timestamp,
        jsonb_array_elements(raw_json) as station
    from bronze.bikepoint_raw
),

parsed as (
    select
        raw_id,
        snapshot_timestamp,

        station ->> 'id' as bikepoint_id,
        station ->> 'commonName' as station_name,
        station ->> 'placeType' as place_type,
        (station ->> 'lat')::numeric as latitude,
        (station ->> 'lon')::numeric as longitude,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbbikes'
            limit 1
        )::integer as nb_bikes,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbdocks'
            limit 1
        )::integer as nb_docks,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbspaces'
            limit 1
        )::integer as nb_spaces,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbemptydocks'
            limit 1
        )::integer as nb_empty_docks,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbstandardbikes'
            limit 1
        )::integer as nb_standard_bikes,

        (
            select prop ->> 'value'
            from jsonb_array_elements(station -> 'additionalProperties') prop
            where lower(prop ->> 'key') = 'nbebikes'
            limit 1
        )::integer as nb_ebikes

    from raw
)

select *
from parsed