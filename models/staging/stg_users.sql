with source_data as (

    select
        user_id,
        signup_date,
        country
    from {{ ref('raw_users') }}

),

cleaned as (

    select
        trim(user_id) as user_id,
        try_to_date(signup_date) as signup_date,
        trim(country) as country
    from source_data

),

final as (

    select * from cleaned

)

select * from final
