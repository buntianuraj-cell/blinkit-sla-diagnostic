# Blinkit SLA Diagnostic - Requirements & KPI Definition

## 1. Stakeholder Grid

| Stakeholder | Interest | Influence | Quadrant | Action |
| --- | --- | --- | --- | --- |
| Regional Operations Director | Cares a lot | Can change, approve or block it | Manage Closely | Weekly review, approve rider decisions |
| Dark-store Managers | Cares a lot | Can change the work | Manage Closely | Act on cluster-hour actions |
| Rider-fleet Lead | Cares a lot | Can change the work | Manage Closely | Move riders to bottleneck cells |
| Finance Team | Cares less | Can change, approve or block it | Keep Satisfied | Check cost of adding riders |
| Data Team | Cares a lot | Cannot change the work | Keep Informed | Own delivery time data, match official numbers |
| Category Team | Cares less | Cannot change the work | Monitor | Informed on Fruits & Vegetables delays |

Owners of official numbers: Data Team owns delivery times, Regional Operations Director owns compliance target.

## 2. Questions and Playback

**Poor:** Do you want a bar chart or a line chart?
**Rewritten:** What decision will you make when you see a cluster is late, and what comparison do you need to make it?
**Why poor:** It asks about chart type before the decision is clear.

**Poor:** Should it be real-time?
**Rewritten:** How quickly do you need to know about a problem to act on it, and what happens if you learn a week later?
**Why poor:** It assumes real-time is needed without checking action frequency.

**Poor:** Do you need every late order listed?
**Rewritten:** When a cluster is late, what level of detail helps you decide - cluster-hour summary or individual orders?
**Why poor:** It pushes a long list instead of finding the decision level.

**Playback:** You asked for a real-time dashboard of every late order. What you actually need is a weekly view that tells you which cluster, in which hour band, needs riders or a promotion hold, because today you only get one city average and learn about problems from complaints. I will build a weekly cluster x hour-band diagnostic, not a real-time order list.

## 3. Ask -> Need -> Build

| Ask | Need | Build |
| --- | --- | --- |
| Real-time dashboard | Know within days which cluster to act on | Weekly view by cluster and hour band |
| Every late order listed | See where lateness concentrates | Compliance by cluster, hour band, category |
| Dashboard for all stores | Compare clusters fairly | One KPI, same definition for all cells |

**Need statement:** Regional Operations Director needs to decide weekly which cluster-hour to add riders to so that at least 80% of delivered orders arrive within 10 minutes in every cluster and hour band.

## 4. KPI Definition

- **Name:** Sub-10-Minute Compliance
- **Definition:** Share of delivered orders with delivery_minutes <= 10
- **Question answered:** What share of delivered orders arrived within the 10-minute promise?
- **Formula:** SUM(within_sla) * 100.0 / COUNT(delivery_minutes), where within_sla = 1 if delivery_minutes <= 10, delivered orders only
- **Counted on:** Delivered orders only, cancelled excluded
- **Date used:** order_date
- **Cut by:** City, cluster, hour band, category
- **Target:** 80% in every cluster and every hour band
- **Deadline:** End of next quarter
- **Starting point:** 79.01%
- **Owner:** Regional Operations Director
- **Source:** orders table in blinkit_sla.db

**Boundary note:** Using <= 10 gives overall compliance 79.01%. Using < 10 gives 57.75%. The 21.26 point gap is all orders that took exactly 10 minutes. So <= vs < is not a detail, it must be written down, or the KPI changes completely.

## 5. Decision Log and Scope

| Date | Decision | Agreed by | Why it matters |
| --- | --- | --- | --- |
| 2026-11-22 | Use delivery_minutes <= 10, delivered only | Regional Operations Director, Data Team | Fixes KPI, avoids 21-point swing |
| 2026-11-22 | Weekly review, not real-time | Regional Operations Director, Rider-fleet Lead | Matches how decisions are made |

**Out of scope:**
- Real-time refresh - decisions are weekly, daily data is noisy.
- Individual rider performance - this diagnostic is cluster-hour level only.
