with staged_events as (

    select
        event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        duration
    from {{ ref('stg_event_logs') }}

),

valid_users as (

    select user_id
    from {{ ref('stg_users') }}
    where user_id is not null
      and trim(user_id) <> ''

),

valid_episodes as (

    select episode_id
    from {{ ref('stg_episodes') }}
    where episode_id is not null
      and trim(episode_id) <> ''

),

final as (

    select
        events.event_key,
        events.event_type,
        users.user_id as user_id,
        episodes.episode_id as episode_id,
        events.timestamp,
        events.duration
    from staged_events as events
    inner join valid_users as users
        on events.user_id = users.user_id
    inner join valid_episodes as episodes
        on events.episode_id = episodes.episode_id
    where events.event_type in ('play', 'pause', 'seek', 'complete')
      and events.user_id is not null
      and trim(events.user_id) <> ''
      and events.episode_id is not null
      and trim(events.episode_id) <> ''
      -- Reject implausibly old timestamps and allow up to 24 hours of clock skew.
      and events.timestamp >= '2000-01-01'::timestamp_ntz
      and events.timestamp < dateadd(day, 1, current_timestamp())
      -- Duration is optional, but any supplied value must be non-negative.
      and (
          events.duration is null
          or events.duration >= 0
      )

)

select * from final
