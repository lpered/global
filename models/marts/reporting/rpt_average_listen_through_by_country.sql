with completion_events as (

    select
        events.user_id,
        events.episode_id,
        events.country,
        least(
            events.duration,
            events.episode_duration_seconds
        )::number(18, 6)
        / nullif(
            events.episode_duration_seconds::number(18, 6),
            0
        ) as completion_duration_ratio
    from {{ ref('flat_interaction_events') }} as events
    where events.event_type = 'complete'
      and events.duration is not null
      and events.duration >= 0
      and events.episode_duration_seconds is not null
      and events.episode_duration_seconds > 0

),

user_episode_rates as (

    select
        user_id,
        episode_id,
        country,
        max(completion_duration_ratio)::number(18, 6)
            as completion_duration_ratio
    from completion_events
    group by
        user_id,
        episode_id,
        country

),

final as (

    select
        country,
        count(distinct user_id) as distinct_user_count,
        count(*) as user_episode_observation_count,
        avg(completion_duration_ratio)::number(18, 6)
            as average_listen_through_rate,
        (avg(completion_duration_ratio) * 100)::number(18, 2)
            as average_listen_through_percentage
    from user_episode_rates
    group by country
    order by country

)

select * from final
