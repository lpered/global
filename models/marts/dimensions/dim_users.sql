with final as (

    select
        user_id,
        signup_date,
        coalesce(country, 'NOT MAPPED') as country
    from {{ ref('stg_users') }}
    where user_id is not null
      and trim(user_id) <> ''

)

select * from final
