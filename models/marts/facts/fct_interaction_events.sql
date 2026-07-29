with final as (

    select
        event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        cast(timestamp as date) as event_date,
        duration
    from {{ ref('int_valid_events') }}

)

select * from final
