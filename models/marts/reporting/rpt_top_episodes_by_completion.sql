with latest_event as (

    select max(timestamp) as max_event_timestamp
    from {{ ref('flat_interaction_events') }}

),

final as (

    select
        events.episode_id,
        events.episode_title as title,
        events.podcast_id,
        count(*) as completion_count
    from {{ ref('flat_interaction_events') }} as events
    cross join latest_event
    where events.event_type = 'complete'
      and cast(events.timestamp as date)
          >= dateadd(
              day,
              -6,
              cast(latest_event.max_event_timestamp as date)
          )
      and events.timestamp <= latest_event.max_event_timestamp
    group by
        events.episode_id,
        events.episode_title,
        events.podcast_id
    order by
        completion_count desc,
        events.episode_id
    limit 10

)

select * from final
