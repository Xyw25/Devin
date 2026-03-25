# Scheduling & Automation Guide

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — Scheduled Sessions](https://docs.devin.ai/product-guides/scheduled-sessions)
> - [Cognition Blog — Devin Can Now Schedule Devins](https://cognition.ai/blog/devin-can-now-schedule-devins)

---

## When to Use Schedulers

| Use Case | Schedule Type | Example |
|----------|--------------|---------|
| Recurring maintenance | Recurring (cron) | Weekly dependency check |
| Daily reporting | Recurring (cron) | Weekday standup summary |
| One-time delayed action | One-time | Scheduled deployment verification |
| Health monitoring | Recurring (cron) | Every 6 hours: run validation scripts |

**Do not use schedulers for:** ad-hoc work, investigation tasks, or one-off
implementation work. Use manual sessions for those.

---

## Creating a Schedule

Two paths:
1. **From input box:** Three-dot menu -> "Schedule Devin"
2. **From settings:** Settings -> Schedules -> "Create schedule"

Or tell Devin directly: _"Schedule this for every Monday at 9am"_

---

## Configuration Options

| Option | Description | Recommendation |
|--------|-------------|----------------|
| Name | Descriptive identifier | Use action-oriented names: `weekly-dependency-check` |
| Agent | Devin, Data Analyst, or Advanced | Default to Devin for code-related tasks |
| Playbook | Optional but recommended | Always attach one for consistency |
| Repository | Specific or auto-detect | Pin to specific repo for predictable behavior |
| Notifications | Always / On failure / Never | Use "On failure" for stable recurring tasks |

---

## Cron Expression Format

Standard 5-field format. **All times are UTC** (displayed in local timezone in UI).

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sunday=0)
│ │ │ │ │
* * * * *
```

### Common Expressions

| Schedule | Cron Expression | Notes |
|----------|----------------|-------|
| Every weekday at 9am UTC | `0 9 * * 1-5` | Monday-Friday |
| Every Monday at 8:30am UTC | `30 8 * * 1` | Weekly check-in |
| Every 6 hours | `0 */6 * * *` | Health monitoring |
| First of month at midnight | `0 0 1 * *` | Monthly report |
| Every 30 minutes | `*/30 * * * *` | Use sparingly — ACU cost adds up |
| Weekdays at 6pm UTC | `0 18 * * 1-5` | End-of-day summary |

### Modes
- **Visual Mode:** Presets for Hourly, Daily (specific time), Weekly (selected days)
- **Custom Mode:** Enter cron expression directly

---

## Cron Gotchas

Common mistakes that cause schedules to fire at the wrong time or too often:

### UTC vs Local Time Confusion

Cron expressions in Devin are evaluated in **UTC**. If you want 9am US Eastern:
- EST (winter): `0 14 * * *` (UTC-5, so 9 + 5 = 14)
- EDT (summer): `0 13 * * *` (UTC-4, so 9 + 4 = 13)

You must update the cron expression when daylight saving time changes, or
accept a 1-hour shift twice a year. The UI shows local time but the
underlying expression is always UTC.

### Day-of-Week Numbering

- Sunday = 0 (also accepted as 7 in some implementations)
- Monday = 1
- Saturday = 6

Common mistake: using `1-5` thinking it means Sunday-Thursday. It actually
means **Monday-Friday**. Double-check with a cron visualizer.

### Month Numbering

- Months are 1-12 (January = 1, December = 12)
- **Not** 0-11 like JavaScript's `Date.getMonth()`
- `0 9 1 0 *` is invalid — there is no month 0

### Wildcard Combinations That Fire Too Often

| Expression | Intended | Actual | Fix |
|------------|----------|--------|-----|
| `* * * * *` | Once a day | Every minute (1440/day) | `0 9 * * *` |
| `0 * * * *` | Once a day | Every hour (24/day) | `0 9 * * *` |
| `*/5 * * * *` | Every 5 min during work hours | Every 5 min 24/7 (288/day) | `*/5 9-17 * * 1-5` |
| `0 9 * * *` on all 7 days | Weekdays only | Includes weekends | `0 9 * * 1-5` |

**Safety rule:** Always calculate how many times per day/week your expression
fires before deploying. Multiply by ACU-per-run to get total cost.

---

## State Persistence Between Runs

Scheduled runs maintain state between executions. This is a key feature —
each run builds on context from the previous run rather than starting fresh.

### State Persistence Pattern

```
Scheduled run starts
  |
  v
Read state from DevinStorage
  (analyses/*.json, or dedicated state file)
  |
  v
Determine delta since last run
  (new work items, changed commits, etc.)
  |
  v
Perform work on delta only
  |
  v
Write updated state to DevinStorage
  |
  v
Commit and push
  |
  v
Session ends — state persists for next run
```

### Dedicated State Files

For scheduled tasks that don't fit the analysis JSON pattern, create a
dedicated state file:

```
DevinStorage/schedules/{task-name}-state.json
```

---

## State Persistence Patterns

Detailed conventions for how scheduled tasks store and manage state across runs.

### Directory Structure

All schedule state files live under `DevinStorage/schedules/`:

```
DevinStorage/
  schedules/
    daily-standup-state.json
    weekly-dependency-check-state.json
    health-monitor-state.json
    api-version-check-state.json
```

### State File Schema Conventions

Every state file should follow this base schema:

```json
{
  "taskName": "weekly-dependency-check",
  "version": 1,
  "lastRunAt": "2026-03-24T08:00:00Z",
  "lastRunStatus": "success",
  "runCount": 42,
  "runHistory": [
    {
      "runAt": "2026-03-24T08:00:00Z",
      "status": "success",
      "acuUsed": 2.1,
      "summary": "Checked 48 deps, 0 outdated"
    }
  ],
  "taskSpecificState": {
    "// task-specific fields go here"
  }
}
```

Key fields:
- **version** — integer counter, incremented each run. Useful for detecting missed runs.
- **lastRunAt** — ISO 8601 timestamp of the most recent execution.
- **lastRunStatus** — `"success"`, `"failure"`, or `"partial"`.
- **runCount** — total number of completed runs.
- **runHistory** — array of recent run summaries (keep bounded; see trimming below).
- **taskSpecificState** — object for whatever the task needs to track between runs.

### Version Counters and Run History

The `version` counter serves as a monotonic sequence number. If you expect
daily runs and the version jumps by more than 1 between two entries, a run
was skipped (schedule was paused, Devin was down, etc.).

The `runHistory` array provides an audit trail. Each entry records:
- When the run happened
- Whether it succeeded
- How many ACU it consumed
- A one-line summary of what was done

### Trimming Old State Entries

To prevent state files from growing indefinitely, trim `runHistory` to the
most recent N entries at the end of each run:

```
Max entries by frequency:
  - Every 30 min:  keep last 48 entries  (~1 day)
  - Every 6 hours: keep last 28 entries  (~1 week)
  - Daily:         keep last 30 entries  (~1 month)
  - Weekly:        keep last 12 entries  (~3 months)
  - Monthly:       keep last 12 entries  (~1 year)
```

Trimming logic should be part of the playbook's cleanup step. Example:

```
runHistory = runHistory.slice(-30)  // keep last 30 entries
```

Old entries beyond the trim window are lost. If you need long-term history,
export to a separate archive file or ADO Wiki page before trimming.

---

## Cumulative Cost Calculator

Use this table to estimate the ongoing ACU cost of scheduled tasks at
different frequencies. Multiply ACU-per-run by the number of runs in each
time period.

| Frequency | Runs/Day | ACU/Run | Daily ACU | Weekly ACU | Monthly ACU |
|-----------|----------|---------|-----------|------------|-------------|
| Every 30 min | 48 | 1.0 | 48.0 | 336.0 | 1,440.0 |
| Every 6 hours | 4 | 1.0 | 4.0 | 28.0 | 120.0 |
| Daily (weekdays) | 1 | 2.0 | 2.0 | 10.0 | 43.0 |
| Daily (all days) | 1 | 2.0 | 2.0 | 14.0 | 60.0 |
| Weekly | 0.14 | 3.0 | 0.43 | 3.0 | 12.9 |
| Monthly | 0.03 | 3.0 | 0.10 | 0.70 | 3.0 |

### Example: This Repo's Schedules

| Schedule | Frequency | ACU/Run | Monthly ACU |
|----------|-----------|---------|-------------|
| Daily standup report | Weekdays | 2.0 | 43.0 |
| Weekly dependency check | Weekly | 3.0 | 12.9 |
| Health monitoring | Every 6 hours | 1.0 | 120.0 |
| API version check | Weekly | 1.0 | 4.3 |
| Feature flag cleanup | Weekly | 3.0 | 12.9 |
| **Total** | | | **~193 ACU/month** |

### Cost Control Guidelines

- **High-frequency schedules (< 6 hours):** Keep ACU/run at <= 1. These add up fast.
- **Daily schedules:** Target <= 2 ACU/run. Monthly cost = ~43-60 ACU.
- **Weekly schedules:** Can afford up to 3-5 ACU/run. Monthly cost stays manageable.
- **Review monthly:** Sum up all schedule costs monthly. If total exceeds your
  budget, reduce frequency or optimize playbooks to lower ACU/run.

---

## Automation Recipes

### Recipe 1: Daily Standup Report
- **Schedule:** `0 9 * * 1-5` (weekdays 9am UTC)
- **Playbook:** Query ADO for work items updated since yesterday, summarize
- **Output:** Post summary to designated Wiki page or work item
- **ACU target:** <= 2

### Recipe 2: Weekly Dependency Update Check
- **Schedule:** `0 8 * * 1` (Monday 8am UTC)
- **Playbook:** Scan for outdated dependencies, create work items for updates
- **State:** Track which dependencies were already flagged in state file
- **ACU target:** <= 3

### Recipe 3: Health Monitoring
- **Schedule:** `0 */6 * * *` (every 6 hours)
- **Playbook:** Run `scripts/maintenance/validate-scripts.sh`, report failures
- **State:** Track last successful run timestamp
- **ACU target:** <= 1

### Recipe 4: API Version Deprecation Check
- **Schedule:** `0 8 * * 1` (Monday 8am UTC)
- **Playbook:** Run `scripts/maintenance/check-api-versions.sh`
- **Output:** Create work item if deprecation detected
- **ACU target:** <= 1

### Recipe 5: Feature Flag Cleanup
- **Schedule:** `0 9 * * 1` (Monday 9am UTC)
- **Playbook:** Scan for feature flags at 100% rollout for 14+ days, flag for removal
- **ACU target:** <= 3

---

## Attaching Playbooks to Schedules

**Always attach a playbook to scheduled tasks.** Without a playbook:
- Scheduled sessions may drift in behavior between runs
- Results become inconsistent and harder to debug
- No forbidden-actions guardrails

With a playbook:
- Same procedure every time
- Clear deliverables and exit conditions
- ACU budget enforced
- Forbidden actions prevent risky improvisation

---

## Do's and Don'ts

### Do

- Set ACU limits on all scheduled sessions
- Monitor cumulative ACU consumption of recurring schedules
- Use state persistence to avoid re-processing
- Attach playbooks for consistent behavior
- Use "On failure" notifications for stable recurring tasks
- Start with weekly frequency, increase only if needed
- Pin to specific repository for predictable behavior

### Don't

- Schedule expensive (L/XL) sessions to run frequently
- Rely on in-memory state across scheduled runs
- Schedule without monitoring — costs accumulate silently
- Forget that cron times are UTC
- Mix scheduled and manual objectives in one schedule
- Create schedules without testing the playbook manually first
