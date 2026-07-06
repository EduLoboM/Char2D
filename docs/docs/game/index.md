# Game Design Document

Design logs, mechanics descriptions, and gameplay systems.

---

## Game Loop

The game loop is divided into three distinct phases:

### 1. Pre-Dungeon Phase
Set in the **City**, a chaotic hub where players prep for the run:
- **Party Configuration:** Draft a team of up to 3 members using captured monsters and hired NPCs.
- **Preparation:** Purchase equipment/items, upgrade traits, acquire sidequests, and converse with town characters.

---

### 2. Dungeon Phase
The main gameplay block where players navigate a procedurally generated dungeon. Players traverse nodes on a map representing a floor, aiming to find the portal to advance. The dungeon consists of **5 floors** in total.

#### Node Types
<div className="doc-grid">
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>flash_on</span>
      <h4 style={{ margin: 0 }}>Normal Combat</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Standard battle against a regular group of regional monsters.
    </p>
  </div>
  
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>whatshot</span>
      <h4 style={{ margin: 0 }}>Super Combat</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Elite battle against tougher, randomized enemy compositions.
    </p>
  </div>
  
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>redeem</span>
      <h4 style={{ margin: 0 }}>Treasure Node</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Find loot, items, or modifiers that can shift run synergy.
    </p>
  </div>
  
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>storefront</span>
      <h4 style={{ margin: 0 }}>Utility Node</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Visit the shopkeeper or rest/heal at the Tavern.
    </p>
  </div>
  
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>military_tech</span>
      <h4 style={{ margin: 0 }}>Boss Node</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Defeat the floor boss to unlock progression to the next floor.
    </p>
  </div>
  
  <div className="glass-card" style={{ padding: '1.25rem' }}>
    <div style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
      <span className="material-icons-outlined" style={{ color: 'var(--ifm-color-primary)', fontSize: '1.5rem' }}>explore</span>
      <h4 style={{ margin: 0 }}>Event Node</h4>
    </div>
    <p style={{ fontSize: '0.85rem', margin: 0, opacity: 0.8, lineHeight: '1.4' }}>
      Text-based events or choices with variable outcomes.
    </p>
  </div>
</div>

---

### 3. Combat Phase
Combat mixes turn-based menu strategy with active dodging mechanics (inspired by Deltarune).

1. **Strategy Selection:** The party stands on the left, enemies on the right. Commands are selected via a bottom command panel.
2. **Dodging Phase:** Once inputs are submitted, players enter a bullet dodging segment. Control a soul hitbox inside a grid space to dodge active waves of enemy attacks.

#### Commands
- **Fight:** Select weapon/monster skills. Skills consume TP, trigger distinct minigames (damage scales based on performance), and utilize **Damage Types** (Slash, Pierce, Blunt) and status **Synergies**.
- **Defend:** Choose Evade (shrinks soul hitbox), Guard (reduces damage percentage), or Counter (deals flat return damage when hit). All defenses generate TP.
- **Items:** Consume utility items to heal or apply temporary combat buffs.
- **Action:** Context-specific combat actions to gather intel, weaken enemies, or capture them.

#### Status Synergies
Skills can trigger or stack seven synergy types:
- <span className="material-icons-outlined synergy-icon synergy-bleed">water_drop</span> **Bleed:** Deal potency damage whenever the target acts. 1 count decays per action.
- <span className="material-icons-outlined synergy-icon synergy-burn">local_fire_department</span> **Burn:** Deal potency damage at the end of the target's turn. 1 count decays per turn.
- <span className="material-icons-outlined synergy-icon synergy-charge">bolt</span> **Charge:** Self-stacking multiplier that builds power for the next attack.
- <span className="material-icons-outlined synergy-icon synergy-sinking">trending_down</span> **Sinking:** Drains 1 count on hit to increase the target's Mercy Meter by the current potency.
- <span className="material-icons-outlined synergy-icon synergy-poise">adjust</span> **Poise:** Builds crit chance (`potency * 5%`). Critical hits consume 1 count and deal +20% damage.
- <span className="material-icons-outlined synergy-icon synergy-rupture">heart_broken</span> **Rupture:** Inflicts extra potency damage on hits. 1 count decays per hit.
- <span className="material-icons-outlined synergy-icon synergy-tremor">vibration</span> **Tremor:** Drains count on hit to reduce the enemy's Stagger threshold by its potency.

#### Target Meters
- **Health:** Depletion kills the target.
- **Stagger:** When depleted, the enemy is stunned for 1 turn. Stagger values reset next turn.
- **Mercy:** Higher values reduce enemy damage output and make them susceptible to sparing or capture.

---

### 4. Post-Dungeon Phase
At the end of a run (victory or defeat):
- **Reset:** All standard currency and items are wiped.
- **Memories:** Players save a **Memory** item providing persistent starting perks, traits, or exceptions (e.g. keeping a captured monster) for future runs.