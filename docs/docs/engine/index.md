# Engine Architecture

Architecture breakdown of the **Char2D** game engine built in Beef Lang.

---

## System Architecture Tree

The following diagram maps the primary systems, core components, and their sub-modules:

```mermaid
graph LR
    Core[Engine Core Loop] --> Render[Rendering System]
    Core --> Phys[Physics & Collision]
    Core --> Input[Input Handler]
    Core --> Audio[Audio Manager]
    Core --> Event[Dialogue & Event System]

    Render --> Sprites[Sprite Manager]
    Render --> Tilemaps[Tilemap Layering]
    Render --> Camera[Viewport Camera]

    Phys --> Grid[Grid Constraints]
    Phys --> Collisions[AABB Collisions]

    Input --> Bindings[Action Mappings]
    Input --> Polling[Dodge Polling]

    Audio --> SFX[SFX Buffer]
    Audio --> BGM[BGM Crossfader]

    Event --> Parser[Dialogue Tree Parser]
    Event --> State[State Persistence]

    classDef renderStroke stroke:#ff4d4d,stroke-width:2px;
    classDef physStroke stroke:#ffd43b,stroke-width:2px;
    classDef inputStroke stroke:#3ecc5f,stroke-width:2px;
    classDef audioStroke stroke:#3b82f6,stroke-width:2px;
    classDef eventStroke stroke:#c084fc,stroke-width:2px;

    class Render,Sprites,Tilemaps,Camera renderStroke;
    class Phys,Grid,Collisions physStroke;
    class Input,Bindings,Polling inputStroke;
    class Audio,SFX,BGM audioStroke;
    class Event,Parser,State eventStroke;
    style Core stroke:#adb5bd,stroke-width:3px;
```