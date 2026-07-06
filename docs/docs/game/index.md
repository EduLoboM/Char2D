# Game Design Document

Design logs, mechanics descriptions, and gameplay systems.

---

## Game Loop

| Phase | Location / Context | Key Mechanics & Activities |
| :--- | :--- | :--- |
| <span className="material-symbols-outlined icon-inline">location_city</span> **1. Pre-Dungeon** | **Big City** | Draft a team of up to 3 members using captured monsters and hired NPCs. Purchase items/gear, upgrade traits, accept sidequests, and talk to townsfolk to prepare for the run. |
| <span className="material-symbols-outlined icon-inline">layers</span> **2. Dungeon** | **Procedural Map** | Traverse map nodes representing a floor (5 floors total) to locate the portal and advance, managing paths and node choices dynamically. |
| <span className="material-symbols-outlined icon-inline">swords</span> **3. Combat** | **Battle Field** | Pick skills, actions, items, or defenses via a bottom command panel, and then control a soul hitbox inside a grid space to active dodge waves of enemy attacks. |
| <span className="material-symbols-outlined icon-inline">history</span> **4. Post-Dungeon** | **Run Resolution** | Wipe all standard run-specific currency and items. Save a Memory or Blessing item providing persistent starting perks, traits, quests or exceptions for subsequent runs. |

---

### Dungeon Node Types

| Node Type | Description |
| :--- | :--- |
| <span className="material-symbols-outlined icon-inline">flash_on</span> **Normal Combat** | Standard battle against a regular group of regional monsters. |
| <span className="material-symbols-outlined icon-inline">whatshot</span> **Super Combat** | Elite battle against tougher, randomized enemy compositions. |
| <span className="material-symbols-outlined icon-inline">redeem</span> **Treasure Node** | Find loot, items, or modifiers that can shift run synergy. |
| <span className="material-symbols-outlined icon-inline">storefront</span> **Utility Node** | Visit the shopkeeper or rest/heal at the Tavern. |
| <span className="material-symbols-outlined icon-inline">military_tech</span> **Boss Node** | Defeat the floor boss to unlock progression to the next floor. |
| <span className="material-symbols-outlined icon-inline">explore</span> **Event Node** | Text-based events or choices with variable outcomes like weather for example. |

---

## Combat System

| Combat Stage | Objective | Layout & Gameplay Mechanics |
| :--- | :--- | :--- |
| <span className="material-symbols-outlined icon-inline">ads_click</span> **1. Strategy Selection** | Input party commands | Party stands on the left, enemies on the right. Commands are selected via the bottom command panel. |
| <span className="material-symbols-outlined icon-inline">videogame_asset</span> **2. Dodging Phase** | Survive bullet-hell waves | Once inputs are submitted, control a soul hitbox inside a grid space to dodge active projectile patterns. Closely avoiding an attack generates TP, while being hit reduces HP of the targeted units. |


### Commands

| Command | Usage & Costs | Mechanics & Effects |
| :--- | :--- | :--- |
| <span className="material-symbols-outlined icon-inline">sports_kabaddi</span> **Fight** | Weapon & Monster Skills (Consumes TP) | Triggers interactive minigames where damage scales based on timing/performance. Utilizes Damage Types that affects damage based on weakness and resistances (Slash, Pierce, Blunt) and status synergies. |
| <span className="material-symbols-outlined icon-inline">shield</span> **Defend** | Evade, Guard, or Counter (Generates TP) | The evade shrinks soul hitbox to slip through tight patterns, the guard gives a flat percentage reduction of incoming damage and the counter deals flat return damage when hit by projectiles. |
| <span className="material-symbols-outlined icon-inline">healing</span> **Items** | Utility Consumables (No TP Cost) | Consumes  inventory items to heal HP/TP or apply temporary stats/synergy buffs or activate special events. |
| <span className="material-symbols-outlined icon-inline">auto_awesome</span> **Action** | Tactical Contextual Skills | Context-dependent actions to inspect enemy stats, weaken their staggering threshold, or attempt to capture monsters. |

### Status Synergies

<div className="synergies-table-container">

| Synergy | Damage/Effect Type | Mechanics & Decay Behavior |
| :--- | :--- | :--- |
| <span className="material-icons-outlined synergy-icon synergy-bleed">water_drop</span> **Bleed** | Potency Damage | Deals damage whenever the target performs any action. Decays 1 count per action. |
| <span className="material-icons-outlined synergy-icon synergy-burn">local_fire_department</span> **Burn** | Potency Damage | Deals damage at the end of the target's turn. Decays 1 count per turn. |
| <span className="material-icons-outlined synergy-icon synergy-charge">bolt</span> **Charge** | Damage Multiplier | Self-stacking damage multiplier. Fully consumed on the next skill execution. |
| <span className="material-icons-outlined synergy-icon synergy-sinking">trending_down</span> **Sinking** | Mercy Meter Boost | Drains 1 count on hit to increase the target's Mercy Meter by the current potency. |
| <span className="material-icons-outlined synergy-icon synergy-poise">adjust</span> **Poise** | Crit Chance Stat | Increases crit chance by potency x 5%. Crits consume 1 count and deal +20% damage. |
| <span className="material-icons-outlined synergy-icon synergy-rupture">heart_broken</span> **Rupture** | Hit Bonus Damage | Inflicts extra damage on hit equal to the status potency. Decays 1 count per hit. |
| <span className="material-icons-outlined synergy-icon synergy-tremor">vibration</span> **Tremor** | Stagger Gauge Drain | Drains count on hit to reduce the target's Stagger threshold by its potency. |

</div>

### Target Meters

| Meter | Visual Indicator | Baseline Behavior & Maximum Effects |
| :--- | :--- | :--- |
| <span className="material-symbols-outlined icon-inline">favorite</span> **Health** | Red Bar | Represents vital status. Reaching 0 defeats/kills the combatant. |
| <span className="material-symbols-outlined icon-inline">dangerous</span> **Stagger** | Yellow Shield Bar | Shielding boundary. Reaching 0 stuns the target for 1 round; resets next turn. |
| <span className="material-symbols-outlined icon-inline">handshake</span> **Mercy** | Blue Harmony Bar | Behavioral alignment. Higher values reduce enemy attack power and allow sparing/capturing. |