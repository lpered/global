{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='event_key',
        on_schema_change='sync_all_columns'
    )
}}

with source_data as (

    select
        event_type,
        user_id,
        episode_id,
        timestamp,
        duration
    from {{ ref('raw_event_logs') }}

    {#
    Enable this filter when the source provides a reliable loaded_at column:

    {% if is_incremental() %}
    where loaded_at > (
        select coalesce(max(loaded_at), '1900-01-01'::timestamp_ntz)
        from {{ this }}
    )
    {% endif %}
    #}

),

cleaned as (

    select
        lower(trim(event_type)) as event_type,
        trim(user_id) as user_id,
        trim(episode_id) as episode_id,
        try_to_timestamp_ntz(trim(timestamp)) as timestamp,
        cast(duration as number(18, 3)) as duration
    from source_data

),

keyed as (

    select
        {{ generate_event_key(
            'event_type',
            'user_id',
            'episode_id',
            "to_varchar(timestamp, 'YYYY-MM-DD HH24:MI:SS.FF9')",
            'to_varchar(duration)'
        ) }} as event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        duration

    from cleaned

),

dedup as (

    select
        event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        duration
    from keyed
    qualify row_number() over (
        partition by
            event_type,
            user_id,
            episode_id,
            timestamp,
            duration
        order by timestamp desc
    ) = 1

),

final as (

    select * from dedup

)

select * from final
