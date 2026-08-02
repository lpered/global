---
title: Podcast Analytics
---

# Podcast Analytics

Reporting dashboards backed by the production dbt `rpt_*` models.

```sql top_episodes
select *
from warehouse.rpt_top_episodes_by_completion
order by completion_count desc, episode_id
```

```sql listen_through
select *
from warehouse.rpt_average_listen_through_by_country
order by average_listen_through_percentage desc, country
```

```sql engagement
select *
from warehouse.rpt_highly_engaged_daily_listeners
```

## Listener engagement

<Grid cols=2>
    <BigValue
        data={engagement}
        value=distinct_qualifying_user_count
        title="Highly Engaged Listeners"
        fmt=num0
    />
    <BigValue
        data={engagement}
        value=qualifying_user_day_count
        title="Qualifying User-Days"
        fmt=num0
    />
</Grid>

## Top episodes by completion

<BarChart
    data={top_episodes}
    x=title
    y=completion_count
    swapXY=true
    sort=false
    title="Completions in the Latest Seven-Day Window"
/>

<DataTable data={top_episodes} rows=10>
    <Column id=title title="Episode"/>
    <Column id=podcast_id title="Podcast"/>
    <Column id=completion_count title="Completions" fmt=num0/>
</DataTable>

## Average listen-through by country

<BarChart
    data={listen_through}
    x=country
    y=average_listen_through_percentage
    yFmt=num1
    yAxisTitle="Percent"
    title="Average Listen-Through"
/>

<DataTable data={listen_through}>
    <Column id=country title="Country"/>
    <Column id=distinct_user_count title="Listeners" fmt=num0/>
    <Column id=user_episode_observation_count title="User-Episode Observations" fmt=num0/>
    <Column id=average_listen_through_rate title="Average Listen-Through" fmt=pct1/>
</DataTable>
