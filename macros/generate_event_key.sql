{% macro generate_event_key(
    event_type,
    user_id,
    episode_id,
    event_timestamp,
    event_duration
) -%}

    {{ dbt_utils.generate_surrogate_key([
        event_type,
        user_id,
        episode_id,
        event_timestamp,
        event_duration
    ]) }}

{%- endmacro %}
