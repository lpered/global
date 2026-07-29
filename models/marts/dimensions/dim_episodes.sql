with final as (

    select
        episode_id,
        podcast_id,
        episode_title,
        release_date,
        episode_duration_seconds,
        is_valid_duration
    from {{ ref('stg_episodes') }}
    where episode_id is not null
      and trim(episode_id) <> ''

)

select * from final
