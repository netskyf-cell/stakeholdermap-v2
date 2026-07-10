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
**What it does today:** Stakeholder mapping, relationship scoring, touchpoint logging,
AI-assisted analysis, bulk import, and export. All data created here feeds into
the Transformation OS shell via Supabase.

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
- Stakeholder data stored as JSON inside map records
- Maps stored in Supabase `maps` table (assumed — confirm before editing)
- Touchpoints stored in Supabase `touchpoints` table (live, do not alter)

**Phase 2 (in progress — parallel migration, do not break Phase 1):**
- `stakeholders` table — shared stakeholder records
- `initiatives` table — first-class change initiative object
- `nudges` table — proactive alert layer
- `initiative_members` table — links stakeholders to initiatives

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

## CURRENT SPRINT [LOCAL — update when sprint changes]

**Phase 2 — in progress**
- [ ] Supabase SQL: create `initiatives`, `stakeholders`, `nudges`, `initiative_members` with RLS
- [ ] Adherence heatmap (visual calendar of touchpoints per stakeholder)
- [ ] AI coaching nudges (proactive alerts when a key relationship goes cold)
- [ ] Map name and description editing

**Do not touch right now:**
- `touchpoints` table schema — live and working
- JSON-based stakeholder storage — migrate in parallel, never replace directly
- Existing AI scoring logic in `api/ai.js` — bulk import is working correctly

---

## KNOWN ANTI-PATTERNS FOR THIS REPO [LOCAL + GLOBAL]

| Anti-pattern | What broke | Correct approach |
|---|---|---|
| Hardcoded `max_tokens` in `api/ai.js` | Bulk import: flat 50/50 scores for all stakeholders | Always pass `max_tokens` from request body |
| `/followup` link format | Follow-up Board 404 on Vercel | Always `/#/followup` |
| `/map/${id}` without hash | Open → links broken on refresh | Always `/#/map/${id}` |
| Inline fetch() to Anthropic in HTML | Unauditable, key exposure risk | Route through `api/ai.js` only |
| Altering `touchpoints` schema directly | Would break Transformation OS reads | Add columns via migration only |

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

---

## HANDOFF NOTE

When Claude Code is connected and a team joins:
- [GLOBAL] sections above move to `tos-core/global-ltm.md`
- [LOCAL] sections stay in this file
- Global rules become `copilot-instructions.md` for GitHub Copilot users
- Owner of this file: Frédéric (sprint context) + architect (if/when one joins)
