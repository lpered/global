with interaction_events as (

    select
        event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        event_date,
        duration
    from {{ ref('fct_interaction_events') }}

),

users as (

    select
        user_id,
        signup_date,
        country
    from {{ ref('dim_users') }}

),

episodes as (

    select
        episode_id,
        podcast_id,
        episode_title,
        release_date,
        episode_duration_seconds,
        is_valid_duration
    from {{ ref('dim_episodes') }}

),

final as (

    select
        events.event_key,
        events.event_type,
        events.user_id,
        events.episode_id,
        events.timestamp,
        events.event_date,
        events.duration,
        users.signup_date,
        users.country,
        episodes.podcast_id,
        episodes.episode_title,
        episodes.release_date,
        episodes.episode_duration_seconds,
        episodes.is_valid_duration
    from interaction_events as events
    inner join users
        on events.user_id = users.user_id
    inner join episodes
        on events.episode_id = episodes.episode_id

)

select * from final
