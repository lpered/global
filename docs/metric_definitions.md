# Metric definitions

This glossary is the business and technical contract for the three required
podcast analytics outputs. The source has no session ID, source event ID,
playback position, seek destination, or documented duration semantics.
Accordingly, these are event-based metrics and proxies rather than reconstructed
listening sessions.

## Completion event count

| Property | Definition |
|---|---|
| Technical name | `completion_event_count` |
| Published model | `rpt_top_episodes_by_completion` |
| Business question | Which episodes generated the most completion events in the latest seven-day period in the data? |
| Input model | `flat_interaction_events` |
| Input grain | One valid, exact-deduplicated event |
| Output grain | One episode, limited to the top ten |
| Formula | Count rows where `event_type = 'complete'` |
| Time dimension | `timestamp` |
| Window | Date of maximum valid event timestamp plus the preceding six calendar days |
| Duplicate rule | Exact normalized duplicates are removed upstream |
| Repeated-event rule | Non-identical repeated completion events count separately |
| Null rule | Events without valid keys or timestamps do not enter the fact |
| Limitation | This counts completion signals, not unique users or reconstructed completion sessions |

The dataset maximum is used instead of the current date so the historical mock
extract always produces a meaningful seven-day result.

## Average completion-duration ratio by country

| Property | Definition |
|---|---|
| Technical name | `average_completion_duration_ratio` |
| Published model | `rpt_average_listen_through_by_country` |
| Calculation location | User-episode CTEs inside `rpt_average_listen_through_by_country` |
| Business question | What is the average completion-duration ratio by user country? |
| Input grain | One valid completion event |
| Metric grain before averaging | One user and episode |
| Output grain | One country |
| Event formula | `least(duration, episode_duration_seconds) / episode_duration_seconds` |
| Repeated-event rule | Retain the maximum valid ratio for each user and episode |
| Aggregation | Average user-episode ratios by country |
| Duration filters | Completion duration must be non-null and non-negative; episode duration must be positive |
| Missing country | Presented as `NOT MAPPED` |
| Limitation | Duration meaning is undocumented and sessions cannot be reconstructed |

This metric is a completion-duration proxy. It must not be presented as exact
sessionized listen-through. Taking the maximum per user and episode prevents
replays or repeated completion signals from giving one pair disproportionate
weight. Capping at one prevents duration values above episode runtime from
producing ratios over 100%.

## Highly engaged listener count

| Property | Definition |
|---|---|
| Technical name | `highly_engaged_listener_count` |
| Published model | `rpt_highly_engaged_daily_listeners` |
| Calculation location | User-day CTEs inside `rpt_highly_engaged_daily_listeners` |
| Business question | How many distinct users listened to at least three distinct episodes on the same day? |
| Qualifying event types | `play`, `complete` |
| Deduplication grain | One user, event date, and episode |
| Metric grain | One user and event date |
| Qualification | `distinct_episode_count >= 3` |
| Output grain | One summary row |
| Output metrics | Distinct qualifying users and qualifying user-days |
| Limitation | A play or completion event is treated as evidence of activity; listening depth is unknown |

Pause and seek events do not qualify by themselves. Multiple qualifying events
for the same user, episode, and date count as one episode. The distinct-user
metric counts each qualifying user once across the complete dataset, while the
user-day metric counts every qualifying day.

## Ownership and change control

For this assessment, the analytics engineering owner maintains these
definitions. In production, metric changes should require review from the
analytics owner and relevant product stakeholder. Changes to grain, filters,
duration interpretation, or repeated-event handling are breaking semantic
changes and should be documented and validated before release.
