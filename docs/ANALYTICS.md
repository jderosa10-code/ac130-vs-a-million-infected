# Analytics

Everything the game sends to Roblox Analytics (Creator Hub > Gunship vs a Million Infected > Analytics).
Data only comes from **published, live servers**, not Studio. It shows up after a day or so.

## How it works

| Piece | Where | What it does |
|---|---|---|
| `Convoy.Funnels` | ReplicatedStorage | Every funnel and its numbered steps. Shared by client and server. |
| `Analytics` | ServerScriptService (Script) | Logs everything. Watches player attributes and purchase prompts; checks the client's steps. |
| `AnalyticsClient` | StarterPlayerScripts | Watches the UI (screens, popups, buttons) and the run, and reports steps through `Remotes.Track`. |
| `Remotes.Track` | ReplicatedStorage.Convoy.Remotes | RemoteEvent the client reports on (rate-limited, whitelisted; server-only steps are refused). |

No other script calls these. They only listen, so adding UI won't break them (an unhooked button just isn't counted).

**Studio check:** in a playtest, run `workspace:SetAttribute("DebugAnalytics", true)` on the server; every event prints `[Analytics] ...` in the Output.

**Custom fields on every event:** Field 1 = place (Lobby / Downtown / Dunes / NorthPole), Field 2 = detail (item key, plane, wave...), Field 3 = rank band (Rank0-2, Rank3-5, Rank6-9, Rank10+). Use these to split any chart.

## Funnels

The dashboard shows up to 10 funnel tabs; pick the ones you care about. Steps marked (s) are logged by the server.

| Funnel | Steps |
|---|---|
| **Onboarding** (one time per player) | Joined (s), ProfileLoaded (s), MenuShown, PlayPressed, LobbyChosen, RunStarted, FirstKill, Wave2, Wave5, RunEnded, NextAction, SecondRun, ArmoryOpened, FirstUpgrade (s), AircraftOpened, FirstPlane (s), Wave10, FirstPurchase (s) |
| **Run** (each run) | Started, Wave3, Wave5, Wave10, Wave15, Wave20, Wave30, Ended, PlayAgain |
| **Shop** | Opened, ItemClicked, Purchased (s) |
| **FirstBuy** (2x first-buy packs) | BonusSeen, Clicked, Purchased (s) |
| **GemTopUp** (NEED MORE GEMS popup) | Shown, BuyClicked, Purchased (s) |
| **DebriefPass** (2X GEMS strip) | Shown, Clicked, Purchased (s), BonusGranted (s) |
| **DailyDeal** | TileShown, Opened, BuyClicked, Bought (s) |
| **BattleOffer** (in-run offers + FORTIFY / CASH DROP tiles) | Shown, Clicked, Purchased (s) |
| **StreakOffer** (losing-streak cash drop) | Streak (s), Shown, Clicked, Purchased (s) |
| **SecondChance** | Shown, Clicked, Purchased (s) |
| **Season** | Opened, PremiumClicked, PremiumBought (s) |
| **Ranks** | Opened, SkipClicked, SkipBought (s) |
| **Aircraft** | Opened, RowClicked, ActionClicked, Unlocked (s) |
| **Armory** | Opened, UpgradeClicked, Upgraded (s) |
| **Mechanic** (strikes) | Opened, BuyClicked, StrikeBought (s) |
| **Daily** (login reward) | Opened, ClaimClicked, Claimed (s) |

A purchase lands in the funnel whose button opened the Robux prompt (within 5 minutes); otherwise in its natural funnel (gem pack -> Shop, battle item -> BattleOffer, skip -> Ranks...).

## Economy (Gems)

Every change to a player's gems is logged as a source or sink with a reason:
- Sources: RunReward, DailyReward, FreeReward, SeasonReward, GemPackFirstBuy, PassBonus2x, the gem pack key (IAP), GiftOrRefund.
- Sinks: GunUpgrade, Aircraft, Tracer, Strike, DailyDeal.

## Progression and custom events

- Progression: `Rank` (each rank up), `BestWave` (new best), `Strike` (strike tier bought).
- Custom: `RunEnded` (value = wave), `RunGems`, `RunKills`, `RobuxPurchase`, `PurchaseCancelled`, `TopUpSeeAll`, `QuickBuyClicked`, `GiftClicked`, `DebriefLobby`, `TutorialStarted`.

## Adding a funnel

1. Add it to `Convoy.Funnels.LIST` (append steps; never renumber old ones).
2. Log client steps from `AnalyticsClient` (`T("Funnel", "Step", { key = ..., sku = productId })`) and server steps from `Analytics` (`step(p, "Funnel", "Step", detail)`).
3. Copy all of them to every place (docs/MAPS_AND_SYNC.md).
