{{ config(materialized='view') }}

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

classified as (

    select
        events.*,
        nullif(
            array_to_string(
                array_construct_compact(
                    iff(
                        events.user_id is null or trim(events.user_id) = '',
                        'missing_user_id',
                        null
                    ),
                    iff(
                        events.episode_id is null
                        or trim(events.episode_id) = '',
                        'missing_episode_id',
                        null
                    ),
                    iff(
                        events.event_type is null
                        or trim(events.event_type) = '',
                        'missing_event_type',
                        null
                    ),
                    iff(
                        events.event_type is not null
                        and trim(events.event_type) <> ''
                        and events.event_type not in (
                            'play', 'pause', 'seek', 'complete'
                        ),
                        'unsupported_event_type',
                        null
                    ),
                    iff(
                        events.timestamp is null,
                        'missing_timestamp',
                        null
                    ),
                    iff(
                        events.timestamp is not null
                        and (
                            events.timestamp
                                < '2000-01-01'::timestamp_ntz
                            or events.timestamp
                                >= dateadd(day, 1, current_timestamp())
                        ),
                        'timestamp_out_of_range',
                        null
                    ),
                    iff(
                        events.duration < 0,
                        'negative_duration',
                        null
                    ),
                    iff(
                        events.user_id is not null
                        and trim(events.user_id) <> ''
                        and users.user_id is null,
                        'unknown_user_reference',
                        null
                    ),
                    iff(
                        events.episode_id is not null
                        and trim(events.episode_id) <> ''
                        and episodes.episode_id is null,
                        'unknown_episode_reference',
                        null
                    )
                ),
                '; '
            ),
            ''
        ) as rejection_reason
    from staged_events as events
    left join {{ ref('stg_users') }} as users
        on events.user_id = users.user_id
    left join {{ ref('stg_episodes') }} as episodes
        on events.episode_id = episodes.episode_id

),

final as (

    select
        event_key,
        event_type,
        user_id,
        episode_id,
        timestamp,
        duration,
        rejection_reason
    from classified
    where rejection_reason is not null

)

select * from final
