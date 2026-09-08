# MVP status and remaining path

Updated 2026-09-08. PROJECT_TRACKER.md remains the source of individual task
statuses. This page explains the product-level milestones; a passing build is
not, by itself, a complete MVP.

| Milestone | Status | What is available |
| --- | --- | --- |
| 0: Repository foundation | Complete | Git workflow, main protection, local tracker and decisions |
| 1: Flutter bootstrap | Complete | Runnable app, reusable cards, required CI |
| 2: Initial domain core | Complete | Cards, follow-suit and canonical bidding rules, bidding content validation |
| 3: Bidding coach | Complete | Ten reviewed hands, 53 evaluated choices, concise deterministic coaching |
| 4: Mid-hand training | In progress | One-card commit, safe/probable and derived void-tracking coaching (EC-041/046/047/042); exact-bid pack (EC-043) remains |
| 5: Personal coaching | Not started | Skill aggregation, persistent decisions and weak-area recommendations remain |
| English/مصري | Planned | Glossary confirmed; language switching and translated content remain |
| Training hub and release acceptance | Planned | Navigation/progress overview and final acceptance tests remain |

## Remaining delivery path

1. Add reviewed exact-bid-protection exercises (EC-043), including meaningful
   consequences/continuation where needed. Trick-winner resolution is
   documented (`docs/GAME_RULES_V1.md#trick-winners`) but not yet implemented;
   confirm any further rules needed before relying on turn order or scoring.
2. Define skills, save decision history locally, and recommend practice from
   actual weaknesses (EC-050/051/052).
3. Add the training hub with Continue, Bid, Play, Weak Areas and recent progress
   (EC-053).
4. Implement English/مصري switching, persistence, RTL and portable translations
   using the confirmed glossary (EC-060). Split UI infrastructure and content
   translation into separate checkpoints if necessary.
5. Complete user acceptance and fix issues on the intended device (EC-054).

Planning estimate: **5–9 bounded implementation/review checkpoints**, then any
fixes uncovered during acceptance. This is a scope estimate, not a promised
date or fixed number of PRs. Content review, unresolved rules, localization
testing and user feedback may increase it. Calendar completion also depends on
review/merge cadence and the intended release device.

The MVP is complete when the user can choose bidding or play practice, make
visual decisions, receive reviewed deterministic coaching, resume saved progress,
find weak-area practice, and switch between English and مصري reliably. Accounts,
backend, multiplayer, runtime AI and a full game simulator remain outside scope.
