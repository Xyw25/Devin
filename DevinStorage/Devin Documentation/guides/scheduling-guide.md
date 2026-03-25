# Scheduling & Automation Guide

> Created: 2026-03-25
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
