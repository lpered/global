with distinct_daily_listens as (

    select distinct
        user_id,
        event_date,
        episode_id
    from {{ ref('flat_interaction_events') }}
    where event_type in ('play', 'complete')

),

daily_engagement as (

    select
        user_id,
        event_date,
        count(*) as distinct_episode_count
    from distinct_daily_listens
    group by
        user_id,
        event_date

),

qualifying_user_days as (

    select
        user_id,
        event_date,
        distinct_episode_count
    from daily_engagement
    where distinct_episode_count >= 3

),

final as (

    select
        count(distinct user_id) as distinct_qualifying_user_count,
        count(*) as qualifying_user_day_count
    from qualifying_user_days

)

select * from final
