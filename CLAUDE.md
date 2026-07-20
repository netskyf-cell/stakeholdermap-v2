# CLAUDE.md — StakeholderMap
# This file is read automatically by Claude Code at session start.
# Global rules live in the Claude.ai Project context (global-ltm.md when tos-core repo exists).
# This file covers only what is LOCAL to this repo.
# [GLOBAL] tags = will move to global-ltm.md when Claude Code is connected
# [LOCAL] tags = stays here permanently

---

## WHAT THIS REPO IS [LOCAL]

**Repo:** `stakeholdermap-v2`
**Live URL:** `stakeholdermapper.vercel.app`
**Role:** App 1 of Transformation OS — the primary data entry and analysis tool.
**What it does today:** Stakeholder mapping (influence/interest matrix), relationship
scoring, touchpoint logging, AI-assisted analysis (strategy brief, comms plan, risk
analysis, relationship arcs), bulk import, message drafting, AI coaching nudges,
global quadrant filtering, and export. All data created here feeds into the
Transformation OS shell via Supabase.

This is the PRIMARY data creation app. The Transformation OS shell reads from it.
StakeholderMap must always work as a fully standalone product, even without
Transformation OS running.

---

## REPO STRUCTURE [LOCAL]

```
stakeholdermap-v2/
├── api/
│   └── ai.js            ← Vercel serverless function — ALL AI calls go here
├── index.html           ← Entire frontend — single file, hash-based routing
├── package.json
├── supabase-setup.sql   ← Reference SQL for table setup
├── vercel.json
├── README.md
└── CLAUDE.md            ← This file
```

---

## GLOBAL RULES REFERENCE [GLOBAL]

These rules are maintained in the Claude.ai Project context.
When Claude Code is connected, they will live in `tos-core/global-ltm.md`.
Key rules to remember until then:

- Stack: Vanilla HTML + Babel CDN + Supabase + Vercel serverless (CommonJS)
- Auth: Supabase Auth only — never roll custom auth
- AI calls: always through `api/ai.js` — never inline fetch to Anthropic in HTML
- Routing: hash-based ONLY — all links use `/#/route` — never `/route`
- Security: service role key and ANTHROPIC_API_KEY in Vercel env vars only
- Design tokens: bg `#F2F2EE`, ink `#0A0A0A`, signal `#D6321F`, moss `#5C7A5E`,
  amber `#C87C2A`, hairline `#C7C7C0`, surface `#E9E7DF`, secondary `#4A4A46`
- Fonts: Inter Tight (UI) + JetBrains Mono (data/labels/timestamps)
- Rules: zero rounded corners, no gradients, no glows, no emoji as icons

---

## THIS APP'S ROUTES [LOCAL]

```
/#/           → Home / map list
/#/map/:id    → Individual stakeholder map view
/#/analysis   → AI analysis mode
/#/import     → Bulk import screen
/#/export     → Export screen
/#/followup   → Link out to Transformation OS Follow-up Board
```

Any new screen MUST use `/#/newroute` format.
Never add a route without adding it to this list.

---

## DATA MODEL [LOCAL]

### Storage approach (dual — Phase 1 live, Phase 2 in progress)

**Phase 1 (live today):**
- Stakeholder data stored as JSON inside `maps.stakeholders` JSONB column
- Maps stored in Supabase `maps` table (confirmed schema in `supabase-setup.sql`)
- Touchpoints stored in Supabase `touchpoints` table (live, do not alter)

**`maps` table — columns in use (beyond base schema in supabase-setup.sql):**
- `description` — inline-editable map description (text, default `''`)
- `initiative_id` — FK to `initiatives.id`, nullable — links map to a TOS initiative
- `nudge_thresholds` — JSONB `{manage_closely, keep_satisfied, keep_informed, monitor}` (days)

These columns are written by the app but not in the original `supabase-setup.sql`.
Add them via Supabase migration if they do not exist:
```sql
alter table public.maps
  add column if not exists initiative_id uuid references public.initiatives(id) on delete set null,
  add column if not exists nudge_thresholds jsonb default '{"manage_closely":7,"keep_satisfied":14,"keep_informed":30,"monitor":60}'::jsonb;
```
(`description` already in the SQL file.)

**Phase 2 (in progress — parallel migration, do not break Phase 1):**
- `stakeholders` table — shared stakeholder records (not yet built)
- `initiatives` table — first-class change initiative object (READ only from this app)
- `nudges` table — proactive alert layer (client-computed for now, table not yet built)
- `initiative_members` table — links stakeholders to initiatives (not yet built)

**Migration rule:** Run Phase 2 tables in parallel. Never drop or alter
Phase 1 JSON storage until migration is confirmed complete and tested.

---

## SUPABASE TABLES THIS APP OWNS [LOCAL]

| Table | Operation | Notes |
|---|---|---|
| `touchpoints` | READ + WRITE | This app owns this table — do not alter schema |
| `maps` | READ + WRITE | Map metadata and stakeholder JSON |
| `stakeholders` | READ + WRITE | Phase 2 — not yet built |
| `initiatives` | READ only | Phase 2 — written by Transformation OS |
| `nudges` | READ + WRITE | Phase 2 — not yet built |

**Rule:** `touchpoints` schema is live and must not be altered.
Any new fields needed go in a new column added via migration, never by modifying existing columns.

---

## ENVIRONMENT VARIABLES [LOCAL]

Set in Vercel project settings — never in code:

```
SUPABASE_URL          = https://wcpsbubbnioyeypgtlqi.supabase.co
SUPABASE_SERVICE_KEY  = [in Vercel only]
ANTHROPIC_API_KEY     = [in Vercel only]
```

Supabase anon key is safe to hardcode in `index.html`.

---

## FEATURES SHIPPED [LOCAL — update when features land]

### Phase 1 — Live and complete
- [x] Influence/interest matrix with draggable dot placement
- [x] Stakeholder CRUD (add, edit, delete) with quadrant auto-classification
- [x] Touchpoint logging (type, notes, sentiment_after) — owns `touchpoints` table
- [x] Quadrant-based filter applied globally across Map tab, Touchpoints tab, and recent log
- [x] AI bulk import — extracts stakeholders from free text, falls back to text parser
- [x] AI analysis: Strategy brief, Comms plan, Risk analysis
- [x] Message drafting tab — per-stakeholder AI comms
- [x] Export tab

### Phase 2 — In progress / shipped
- [x] Map name and description inline editing (saves on blur, cancels on Escape)
- [x] AI coaching nudges — computed client-side from touchpoint cadence per quadrant
  - Configurable per-quadrant thresholds (days) stored in `maps.nudge_thresholds` JSONB
  - Collapsed summary strip in header; expands to show individual nudges
  - "Log touchpoint" and "Dismiss" actions per nudge
  - Nudge modal hoisted to root level so it works from any tab
  - Re-computes reactively when `stakeholders`, `touchpoints`, or `nudgeThresholds` change
- [x] Relationship arcs (per-stakeholder)
  - Unlock threshold: ≥10 touchpoints, ≥70% with notes
  - `TpSparkline` component — sentiment dot timeline with hover tooltips
  - `ArcProgressRail` component — shows unlock progress
  - Expandable stakeholder rows in Touchpoints tab
  - AI generates 3-5 sentence narrative referencing specific dates and turning points
  - `max_tokens: 1200`
- [x] Map arc (portfolio-level analysis mode)
  - Unlock threshold: ≥60% of stakeholders with ≥3 touchpoints, ≥30 days of history
  - Reads last 8 touchpoints per stakeholder (token budget control)
  - AI outputs 6-8 sentence reflection on landscape health, recoveries, blindspots
  - `max_tokens: 2500`
- [x] Initiative linking — maps can be linked to a Transformation OS initiative
  - Freemium gate: 1 map per initiative on free plan
  - "View in TOS ↗" deep link to `transformation-os-mauve.vercel.app`
- [x] Initiatives loaded from Supabase `initiatives` table (READ only)

### Still to build
- [ ] Supabase SQL: create `stakeholders`, `nudges`, `initiative_members` with RLS
- [ ] Adherence heatmap (visual calendar of touchpoints per stakeholder)

**Do not touch right now:**
- `touchpoints` table schema — live and working
- JSON-based stakeholder storage — migrate in parallel, never replace directly
- Existing AI scoring logic in `api/ai.js` — bulk import is working correctly

---

## KNOWN ANTI-PATTERNS FOR THIS REPO [LOCAL + GLOBAL]

| Anti-pattern | What broke | Correct approach |
|---|---|---|
| Hardcoded `max_tokens` in `api/ai.js` | Bulk import: flat 50/50 scores for all stakeholders | Always pass `max_tokens` from request body; default now 4096 |
| `/followup` link format | Follow-up Board 404 on Vercel | Always `/#/followup` |
| `/map/${id}` without hash | Open → links broken on refresh | Always `/#/map/${id}` |
| Inline fetch() to Anthropic in HTML | Unauditable, key exposure risk | Route through `api/ai.js` only |
| Altering `touchpoints` schema directly | Would break Transformation OS reads | Add columns via migration only |
| Nudge modal inside a tab | Cannot trigger from nudge strip on other tabs | Hoist modal to root level, outside all tab containers |
| `useEffect` nudge dep array missing deps | Stale closure — nudges don't recompute when data changes | Include `stakeholders`, `touchpoints`, `nudgeThresholds` in dep array |
| Applying quadrant filter only to map | Touchpoints tab and recent log show unfiltered data | Use `filtered` array as single source of truth everywhere |
| Iterating `stakeholders` for filtered lists | Ignores active quadrant filter | Always iterate `filtered`; use `filtered.length` for border/empty state logic |

---

## UI COMPONENTS IN index.html [LOCAL]

These reusable components live in `index.html` (Babel/React). Know them before adding new UI:

| Component | Location (approx. line) | What it does |
|---|---|---|
| `TpSparkline` | ~1124 | Sentiment dot timeline for a stakeholder's touchpoints. Props: `tps`, `dateStart`, `dateEnd`, `height`, `dotSize`, `showAxisLabels`. Dots are interactive (hover scales up, tooltip on hover). |
| `ArcProgressRail` | ~1151 | Progress bar toward an unlock threshold. Props: `label`, `value`, `total`, `pctLabel`. Used for relationship arc and map arc unlock states. |
| `StakeholderForm` | ~1166 | Add/edit stakeholder modal. Props: `editing`, `onAdd`, `onCancel`. |

**Map editor state variables (MapEditor component):**
- `tab` — active tab: `"map"`, `"analysis"`, `"messages"`, `"touchpoints"`, `"import"`, `"export"`
- `filter` — active quadrant filter string or `null`
- `filtered` — derived array: all stakeholders when `filter` is null, else filtered subset. **Use this, not `stakeholders`, for rendering lists.**
- `expandedStakeholderId` — ID of expanded stakeholder row, or `"__nudges__"` for nudge strip, or `null`
- `arcTexts` — `{[stakeholder_id]: string}` — cached AI arc narratives (not persisted)
- `nudgeThresholds` — `{manage_closely, keep_satisfied, keep_informed, monitor}` in days
- `linkedInitiativeId` — UUID of linked initiative or `null`

---

## PRE-FLIGHT QUESTIONS [GLOBAL]

Before writing any code, ask:

1. Which layer — UI (index.html), AI proxy (api/ai.js), or Supabase?
2. Does this need a new table or a column on an existing one?
3. Will this break the live `touchpoints` table or existing JSON stakeholder storage?
4. Is there an AI call — does it pass `max_tokens` from the body and have a fallback?
5. Does every new internal link use `/#/route` format?
6. If this scales to 10x users, what breaks first?

---

## DECISION LOG [LOCAL — append when decisions are made]

| Date | Decision | Reason | Alternative rejected |
|---|---|---|---|
| 2026-07 | JSON stakeholder storage in Phase 1 | Speed to ship | Relational from day 1: over-engineered solo |
| 2026-07 | Parallel migration for Phase 2 schema | Avoid breaking live app | Direct migration: too risky in production |
| 2026-07 | Touchpoints table owned by StakeholderMap | Clear data ownership | Shared write access: conflict risk |
| 2026-07 | Hash-based routing | Vercel single-file constraint | Path routing: 404s on refresh |
| 2026-07 | CommonJS for api/ai.js | Vercel serverless compatibility | ES modules: import errors |
| 2026-07 | Pulse Check as feature here, not separate app | Faster to ship, same audience | Separate app: premature complexity |
| 2026-07 | Client-side nudge computation (not DB-driven) | Avoids `nudges` table + realtime complexity; thresholds are per-map config | Server-side nudge job: premature, no multi-user need yet |
| 2026-07 | `nudge_thresholds` stored as JSONB in `maps` row | Per-map configuration, saved without extra table | Separate `nudge_config` table: over-engineered for one setting |
| 2026-07 | Nudge strip collapsed by default (summary count only) | Prevents alert fatigue; user expands when ready | Expanded by default: visual noise on every load |
| 2026-07 | Reuse `expandedStakeholderId` state with `"__nudges__"` sentinel for nudge expand/collapse | Avoids adding a new state variable | Separate `nudgesExpanded` boolean: unnecessary state proliferation |
| 2026-07 | Global quadrant filter applied to all tabs | Cognitive consistency — filter should work everywhere | Tab-local filters: confusing when switching tabs |
| 2026-07 | `filtered.length` for all list length checks | Correct visual separators and empty states when filter active | `stakeholders.length`: wrong count when filtered |
| 2026-07 | Relationship arc unlock gated behind touchpoint quality threshold | Ensures AI has enough signal to write a meaningful narrative | Always-on: produces shallow output with sparse data |
| 2026-07 | Arc token budgets: 1200 (individual), 2500 (map arc) | Narrative needs room; map arc synthesizes many relationships | Reusing default 2000: too short for map arc portfolio reflection |
| 2026-07 | Map arc reads last 8 touchpoints per stakeholder | Balances context richness vs. token budget at scale | All touchpoints: blows token limit on mature maps |
| 2026-07 | `TpSparkline` rendered inside collapsed stakeholder row (Touchpoints tab) | Shows timeline density at a glance before expanding | Only in expanded row: hides signal users need to decide to expand |
| 2026-07 | Initiative linking with freemium 1-map gate | Monetisation hook; prevents free misuse without server logic | No gate: harder to upsell later |
| 2026-07 | Log touchpoint modal hoisted to root (outside all tabs) | Allows nudge strip to trigger modal from any active tab | Modal inside touchpoints tab: blocked from nudge strip on map tab |

---

## HANDOFF NOTE

When Claude Code is connected and a team joins:
- [GLOBAL] sections above move to `tos-core/global-ltm.md`
- [LOCAL] sections stay in this file
- Global rules become `copilot-instructions.md` for GitHub Copilot users
- Owner of this file: Frédéric (sprint context) + architect (if/when one joins)
