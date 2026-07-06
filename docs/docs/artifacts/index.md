# Asset Registry

Index of design sheets, spritesheets, audio files, and engine configs for the **Char2D** project.

---

## Initial Project Assets

| Asset Name | Type | Status | Workspace Directory | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Game Design Document (GDD)** | Documentation | <span className="badge badge--success">Completed</span> | `/docs/docs/game/` | Core loop, mechanics definitions, and status synergy systems. |
| **Pixel Art Spritesheets** | Visual | <span className="badge badge--secondary">Planned</span> | `/static/img/sprites/` | 32x32 sprite designs for player and enemy entities. |
| **Dungeon Soundtracks** | Audio | <span className="badge badge--secondary">Planned</span> | `/static/audio/bgm/` | Ambient loop files for stage exploration and combat states. |
| **Bullet Wave Configs** | Configuration | <span className="badge badge--secondary">Planned</span> | `/src/config/waves.json` | JSON mapping active wave projectile patterns. |
| **Engine Core Loop Schema** | Diagram | <span className="badge badge--secondary">Planned</span> | `/docs/docs/engine/` | Flowchart detailing engine lifecycle loops. |
| **UI Mockups** | Design | <span className="badge badge--secondary">Planned</span> | `/static/img/ui/` | Interface layouts for combat options and menus. |

---

## Asset Integration Guidelines

1. **Pixel Art:** Align assets to a 32x32 bounding grid. Save in `.png` format with transparency enabled.
2. **Audio:** Compress background tracks in `.ogg` format. Embed looping metadata tags where appropriate.
3. **Registry Updates:** Update this page when committing new files to keep workspace inventory accurate.