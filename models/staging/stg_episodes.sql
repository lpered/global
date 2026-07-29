{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='episode_id',
        on_schema_change='sync_all_columns'
    )
}}

with source_data as (

    select
        episode_id,
        podcast_id,
        title,
        release_date,
        duration_seconds
    from {{ ref('raw_episodes') }}

    {#
    Enable this filter when the source provides a reliable loaded_at column:

    {% if is_incremental() %}
    where loaded_at > (
        select coalesce(max(loaded_at), '2000-01-01'::timestamp_ntz)
        from {{ this }}
    )
    {% endif %}
    #}

),

cleaned as (

    select
        trim(episode_id) as episode_id,
        trim(podcast_id) as podcast_id,
        trim(title) as episode_title,
        try_to_date(release_date) as release_date,
        cast(duration_seconds as number(18, 0)) as episode_duration_seconds
    from source_data

),

final as (

    select
        episode_id,
        podcast_id,
        episode_title,
        release_date,
        episode_duration_seconds,
        (
            episode_duration_seconds is not null
            and episode_duration_seconds > 0
        ) as is_valid_duration -- needed for Listen-Through Rate
    from cleaned

)

select * from final
