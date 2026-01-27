# Game Design Document

## Working Title
Epic Pixels 2D

## Genre
2D Side-Scrolling Army Battle Simulator
Pixel Art · Real-Time · Large-Scale Combat

## Target Platform
- **Windows PC**
- Native resolution: **2560×1440 (1440p)**
- Internal pixel resolution with integer upscale

---

## High-Level Vision

Epic Pixels 2D is a **gritty, large-scale 2D battlefield simulator** where two opposing armies clash across a wide horizontal battlefield.

The player does **not** control individual units. Instead, the game emphasizes:
- Scale
- Brutality
- Physical weight
- Emergent chaos

Infantry are intentionally **small relative to the screen**, reinforcing the feeling of a vast battlefield and leaving room for:
- Tanks
- Mechs
- Heavy artillery
- Air units
- Future monsters and non-human factions

Battles should feel **violent, overwhelming, and alive**, with smoke, debris, and destruction accumulating over time.

---

## Core Pillars

### 1. Epic Scale
- Infantry are expendable and numerous
- Screen space favors terrain, heavy units, and FX
- Backgrounds and parallax reinforce depth and distance

### 2. Weight & Impact
- Units accelerate and decelerate with inertia
- Weapons produce recoil, knockback, and screen shake
- Explosions briefly dominate attention

### 3. Gritty & Brutal Presentation
- Muted military palettes
- High-contrast FX (fire, sparks, smoke, blood mist)
- Persistent smoke, scorch marks, and debris
- Minimal, non-intrusive UI

### 4. Simulation Over Micromanagement
- Units act autonomously
- The player influences battles through composition, not control
- Readability and performance take priority over complexity

---

## Core Game Loop

### Win / Lose Condition
- Each side has a **Command Post (CP)**.
- The battle ends when a CP's HP reaches **0**.
- CPs are large, static structures placed at each battlefield edge.
- Heavy weapons and air units prioritize CPs once in range.

### Player Agency
**Primary interaction:** *pre-battle army composition only*.

The player selects:
- Infantry count
- Heavy units (tanks, later mechs)
- Air units (helicopters, later aircraft)

Once the battle begins, the player observes the simulation unfold.

No mid-battle micromanagement in v1.

### Match Length
- Target duration: **8–12 minutes** for a balanced match
- Shorter if armies are mismatched
- Longer if both sides are armor-heavy

---

## Visual Style

### Art Direction
- Pixel art
- Modern / near-future military aesthetic
- Semi-realistic proportions
- Silhouette-driven readability
- Minimal outlines

### Scale
- Infantry: small on screen, numerous
- Tanks / mechs: 2–4× infantry height
- Air units: occupy upper third of screen
- Future bosses/monsters: significantly larger

### Color & Contrast
- Terrain and background are low contrast
- Units slightly separated from terrain
- FX are bright and saturated for clarity

---

## Resolution & Camera

### Rendering
- Internal resolution: **640×360**
- Upscaled **4×** to 2560×1440
- Nearest-neighbor scaling
- Pixel-snapped camera

### Readability Priority
When the screen is saturated with effects, priority is enforced in this order:
1. Projectiles and tracers
2. Heavy units (tanks, mechs)
3. Infantry
4. Explosions
5. Smoke and ambience

Lower-priority FX are dropped first when caps are reached.

### Camera Behavior
- Mostly static horizontal framing
- Trauma-based screen shake
- Occasional micro-zoom on large explosions
- No constant panning or forced motion

The camera exists to **observe**, not to guide.

---

## Battlefield Model

### Vertical Lanes (Logical)
| Lane | Contents |
|----|----|
| Ground | Infantry |
| Heavy | Tanks, mechs (same level, slightly behind infantry) |
| Air | Helicopters, aircraft, shells, falling debris |

Lanes are logical constraints, not hard visual separations.

### Pathing
- Lane-based forward advance
- No navmesh
- No terrain pathfinding
- Simple obstacle nudging only

Units exist to collide, fire, and die—not to navigate intelligently.

---

## Units (Vertical Slice)

### Infantry – Rifleman
- Numerous and fragile
- Hitscan rifle with tracer visuals
- Low HP
- Short death animation
- Bodies persist briefly, then fade

### Heavy – Tank
- Slow acceleration
- High HP
- Projectile cannon
- Strong recoil and screen shake
- Primary structure and CP killer

### Air – Helicopter
- Rare and powerful
- Strong versus infantry
- Vulnerable to heavy fire
- Occupies air lane exclusively

---

## Combat Model

### Targeting
- Default behavior: **nearest valid enemy in same lane**
- No morale or retreat in v1
- No squad logic

Targeting rules are data-driven and may vary per unit type later.

### Weapons
Hybrid combat model:
- **Hitscan** for bullets
- **Projectile-based** weapons for:
  - Tank shells
  - Rockets
  - Artillery
- Tracers are visual-only and pooled

---

## Violence & Tone

- Gritty military violence trending toward brutal
- Artillery against infantry causes:
  - Multiple casualties
  - Bodies thrown short distances
  - Blood mist and debris
- No gibs initially
- Bodies and damage are readable but not cartoonish

---

## Physics Philosophy

- **Gameplay units:** deterministic, stable movement (no ragdoll chaos)
- **Debris & FX:** limited physics for visual weight
- Physics is used to *sell impact*, not drive gameplay complexity

Examples:
- Shell casings
- Rock chunks
- Explosive debris

---

## Simulation Philosophy

- Determinism is **not a goal**
- Rule-of-cool physics are allowed
- Stability and performance matter more than reproducibility

A fixed simulation tick is still used to keep behavior sane and scalable.

---

## Combat FX (Critical)

### FX Stack
1. Muzzle flash (very short, very bright)
2. Impact spark / blood mist
3. Smoke puff
4. Debris chunks (physics)
5. Scorch marks / decals
6. Lingering atmospheric smoke

### FX Principles
- Smoke lingers and stacks (with caps)
- Explosions briefly dominate attention
- Decals fade slowly over time
- FX readability prioritized over realism

---

## Audio (Design Intent)
(Not implemented yet, but designed for)

- Loud, punchy weapon sounds
- Bass-heavy explosions
- Distant battle ambience
- Layered chaos rather than clean audio separation

---

## Simulation Model

- Two opposing armies spawn from each side
- Units advance, acquire targets, fire, and die autonomously
- AI is intentionally simple and cheap:
  - Periodic target evaluation
  - No per-frame expensive logic
- Performance supports dozens of active units per side

---

## Performance Targets

### Per Side (Typical Battle)
- Infantry: **20–30**
- Heavy units: **3–6**
- Air units: **0–2**

### Global
- Active real projectiles: ~150
- Tracer visuals: pooled and capped per frame
- FX sprites: capped by priority
- Decals: FIFO capped
- Smoke FX lifetime: 2–6 seconds (varied)
- Stable performance at 1440p

---

## Engine & Tech

### Engine
- **Godot**

### Architectural Principles
- Clear separation between:
  - **Simulation**
  - **Combat**
  - **Presentation**
- No presentation logic inside simulation code
- Communication via events, not tight coupling
- Scene-based units (`Soldier.tscn`, `Tank.tscn`, etc.)
- Reusable SpriteFrames
- Object pooling for bullets and FX
- Palette swaps via shaders, not duplicated assets

---

### Scene Graph Overview

**Battlefield.tscn**
- `BattleController`
- `SimRoot`
  - `Units`
  - `Projectiles`
- `RenderRoot`
  - `Sprites`
  - `FX`
  - `Decals`
- `Terrain`
- `Background`
- `CameraRig`

Rationale:
- Keeps draw order deterministic (terrain → units → FX → decals optional)
- Separates simulation from presentation
- Easy culling or caps per layer
- Allows pooling per layer

---

### Core Runtime Systems

#### 1) BattleController (Simulation Orchestrator)
Responsible for:
- Starting/ending battles
- Managing spawn waves
- Updating “macro” simulation at a fixed tick rate (e.g. 10–30 Hz)
- Delegating heavy work to managers

Key concept:
- **Do not** run expensive logic every frame for every unit.
- Use periodic updates and staggered evaluations.

#### 2) Unit Architecture
Units are composed, not deeply inherited.

Core components:
- MovementComponent
- TargetingComponent
- WeaponComponent(s)
- HealthComponent
- TeamComponent

This supports future expansion into monsters, aliens, and magical factions.

All units derive from `UnitBase`:
- Team ID, HP, state machine
- Movement interface
- Target pointer
- Weapon(s)
- Hitbox/hurtbox setup
- Death handling (animation + fade)

**Infantry / Tank / AirUnit**:
- Implement movement + special behaviors
- Infantry and tanks should use deterministic motion (e.g., `CharacterBody2D`)
- Air units can ignore ground collisions and use altitude bands

#### 3) Targeting System (Cheap + Periodic)
- Units evaluate targets on an interval (e.g., every 0.25–1.0s)
- Use distance checks and simple lane/band constraints
- Optional: coarse spatial partitioning later (grid buckets)

Target evaluation is intentionally simple:
- nearest valid enemy in lane
- prefer targets that are closer / higher threat
- avoid per-frame line-of-sight unless required

#### 4) Weapons & Combat
Two weapon types:
- **Hitscan** for bullets (cheap, readable)
- **Projectile** for rockets/grenades/artillery (slower, cinematic)

Each weapon defines:
- fire rate
- range
- damage model
- spread/recoil parameters (presentation + slight gameplay)

Damage pipeline:
`Weapon.fire()` → emits `DamageEvent` → target `Health.apply_damage()`

Avoid deeply coupled calls. Prefer signals or a lightweight event dispatch.

---

### Physics Policy (Determinism First)

- **Units**: `CharacterBody2D` (stable) with handcrafted acceleration/drag
- **Debris**: `RigidBody2D` (short-lived) for “weight candy”
- Keep debris collision layers isolated to avoid interaction explosions.

“Weight” techniques:
- acceleration curves (units take time to start/stop)
- recoil impulses (temporary velocity addition)
- knockback on hit (short, capped)
- dust FX on footsteps / treads

---

### Object Pooling (Mandatory for FX + Bullets)

Pooling targets:
- bullets/hitscan tracers
- muzzle flashes
- hit sparks
- smoke puffs
- small explosions
- decals

Approach:
- A generic `Pool.gd` that pre-warms N instances per type
- Acquire → configure → show
- Return on completion (`animation_finished`, `timeout`, etc.)

Hard caps to prevent runaway:
- max active FX by category
- max decals per screen
- max debris bodies

When caps are reached:
- drop lowest priority FX first (e.g., extra dust puffs)

---

### FX & Decals Architecture

#### FxManager
- Single point for spawning FX
- Applies LOD/caps
- Chooses correct layer node (FX, Decals)
- Supports “FX recipes” per event type:
  - bullet impact: spark + blood mist + tiny smoke
  - explosion: flash + blast sprite + smoke + debris + decal + screen shake

#### DecalManager
- Spawns scorch / crater / blood stains as sprites on ground layer
- Fades alpha over time
- Enforces a cap (FIFO removal)

---

### Camera Rig

**ScreenShake**
- Trauma-based shake (event-driven)
- Explosion size maps to trauma amount
- Decays smoothly
- Optional minor zoom punch on large explosions

**Camera2D**
- Slight smoothing
- Deadzone to prevent micro jitter
- Locked vertical framing unless special units demand otherwise

---

### Timing Model

- Render update: variable (frame rate)
- Simulation tick: fixed (e.g., 20 Hz)
- Targeting tick: staggered per unit group (e.g., infantry offsets)

This keeps:
- movement smooth
- CPU stable with many units
- deterministic behavior across machines

---

### Collision Layers (Suggested)

Define layers early (and keep them stable):
- Units_A
- Units_B
- Projectiles_A
- Projectiles_B
- Terrain
- Debris
- Sensors (target detection, triggers)

Avoid “everything collides with everything.”

---

### Data-Driven Unit Definitions

Use `Resource` assets for units/weapons:
- `UnitDef.tres`
  - HP, speed, mass, lane
  - sprite frames
  - weapon references
- `WeaponDef.tres`
  - fire rate, damage, range
  - hitscan/projectile type
  - FX recipe IDs

This enables rapid iteration without code changes.

---

### Debug & Tooling (Planned)

- Spawn controls (spawn 10/50/100 units per side)
- Toggle FX caps and LOD
- Display unit counts per layer
- Show simulation tick rate + frame time
- “Freeze sim” and “step one tick” for debugging

---


## Non-Goals (Explicit)

- No RTS micromanagement
- No squads
- No morale systems (yet)
- No networking
- No replay system
- No full ragdoll physics
- No hyper-detailed UI or RPG systems

---

## Vertical Slice Milestone

1. Rifleman infantry unit
2. Tank heavy unit
3. Helicopter air unit
4. Two opposing Command Posts
5. Core FX stack
6. Camera shake and parallax

The goal is to **feel** the battle before expanding systems.

---

## Asset Reference

### Project Asset Structure
```
assets/
├── sprites/
│   ├── infantry/          # Space Marine character
│   │   ├── Idle Gun/      # Standing with weapon (4 frames)
│   │   ├── Run with Gun/  # Advancing (10 frames)
│   │   ├── Shoot/         # Firing animation (2 frames)
│   │   ├── Die/           # Death animation (3 frames)
│   │   ├── Misc/          # Bullets, impact effects
│   │   └── Spritesheet.png
│   └── fx/
│       ├── Hit/           # Blue spark impact (3 frames)
│       ├── hits/          # 6 hit effect variations
│       ├── spark/         # Muzzle flash sparks (5 frames)
│       └── Explosion/     # Explosion animation (9 frames)
└── backgrounds/
    └── mountain_dusk/     # Parallax layers
        ├── sky.png
        ├── far-clouds.png
        ├── near-clouds.png
        ├── far-mountains.png
        ├── mountains.png
        └── trees.png
```

### Infantry Animations (Milestone 1)

| Animation | Path | Frames | Use |
|-----------|------|--------|-----|
| Idle Gun | `infantry/Idle Gun/sprites/` | 4 | Standing/shooting stance |
| Run with Gun | `infantry/Run with Gun/sprites/` | 10 | Advancing toward enemy |
| Shoot | `infantry/Shoot/sprites/` | 2 | Firing weapon |
| Die | `infantry/Die/sprites/` | 3 | Death animation |

### FX Assets (Milestone 1)

| Effect | Path | Frames | Use |
|--------|------|--------|-----|
| Hit Spark | `fx/Hit/Sprites/` | 3 | Bullet impact on target |
| Muzzle Spark | `fx/spark/Sprites/` | 5 | Weapon firing effect |
| Bullet | `infantry/Misc/bullet1.png` | 1 | Tracer visual |
| Impact Blast | `infantry/Misc/wall-impact-blast*.png` | 2 | Miss/wall hit |

### Background Layers (Milestone 1)

Ordered back-to-front for parallax:
1. `sky.png` - Static sky with moon
2. `far-clouds.png` - Slow parallax
3. `far-mountains.png` - Slow parallax
4. `near-clouds.png` - Medium parallax
5. `mountains.png` - Medium parallax
6. `trees.png` - Fast parallax (foreground silhouettes)

### Source Library
Original assets sourced from `X:/Gamedev/Assets/` (excluded from version control).

---

