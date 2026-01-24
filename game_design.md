# Game Design Document

## Working Title
Epic Pixels 2D

## Genre
2D Side-Scrolling Army Battle Simulator  
Pixel art · Real-time · Large-scale combat

## Target Platform
- **Windows PC**
- Native resolution: **2560×1440 (1440p)**
- Internal pixel resolution with upscale

---

## High-Level Vision

The game is a **gritty, large-scale 2D battlefield simulator** where two opposing armies clash from opposite sides of a wide horizontal battlefield.

The player does not control individual soldiers directly. Instead, the game focuses on:
- Scale
- Brutality
- Weight
- Emergent chaos

Infantry are intentionally **small relative to the screen**, emphasizing the epic scale of the battlefield and leaving visual and gameplay space for:
- Tanks
- Mechs
- Monsters
- Heavy artillery
- Air units

The battlefield should feel **alive, violent, and overwhelming**, with persistent smoke, debris, and environmental damage accumulating over time.

---

## Core Pillars

### 1. Epic Scale
- Infantry feel like small parts of a massive conflict
- Screen space emphasizes terrain, large units, and FX
- Backgrounds and parallax reinforce battlefield depth

### 2. Weight & Impact
- Movement has inertia and resistance
- Weapons feel powerful through recoil, knockback, and FX
- Explosions displace debris and briefly dominate the screen

### 3. Gritty & Brutal Presentation
- Muted military palettes
- High-contrast FX (fire, sparks, smoke, blood mist)
- Lingering smoke, scorch marks, and destruction
- Minimal “gamey” UI

### 4. Simulation Over Micromanagement
- Units follow simple autonomous behaviors
- Battles unfold dynamically without constant player input
- Readability and performance over individual complexity

---

## Visual Style

### Art Style
- **Pixel art**
- **Modern military aesthetic**
- Semi-realistic proportions (not chibi, not exaggerated)
- Minimal outlines, silhouette-driven readability

### Scale
- Infantry sprites: **32×32 source**, displayed at ~20–30 px tall on screen
- Tanks / mechs: 2–4× infantry height
- Monsters / bosses: significantly larger
- Air units occupy upper vertical space

### Color & Contrast
- Ground and background are low-contrast
- Units slightly brighter/darker than terrain
- FX use high brightness and saturation for readability

---

## Resolution & Camera

### Rendering
- Internal resolution: **426×240** (subject to tuning)
- Upscaled cleanly to **1440p** using nearest-neighbor filtering
- No texture smoothing

### Camera
- Horizontal battlefield focus
- Slight smoothing for cinematic feel
- Deadzone to avoid jitter
- Screen shake driven by explosions and heavy weapons
- No constant camera motion; reacts to battle events

---

## Battlefield Layout

### Vertical Bands
- **Ground band:** infantry, cover, tanks
- **Mid band:** mechs, tall units, large muzzle flashes
- **Air band:** aircraft, artillery shells, falling debris

Bands may overlap visually but help organize collision and targeting.

### Lanes (Logical, Not Visual)
- Ground lane
- Heavy/mid lane
- Air lane

This supports scale while keeping simulation stable.

---

## Units

### Infantry
- Small, numerous, expendable
- Use deterministic movement (CharacterBody2D)
- Weight simulated via acceleration, friction, and knockback
- Short death animations; bodies fade over time

### Heavy Units (Tanks / Mechs)
- Slower acceleration
- Visible recoil and screen shake
- Larger hitboxes and presence
- Kick up dust and debris constantly

### Air Units
- Separate vertical space
- Less frequent, high-impact
- Strong audio/visual identity

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

## Performance Targets (Initial)

- Infantry per side: ~30
- Active projectiles: ~200
- Persistent decals: ~150
- Smoke FX lifetime: 2–6 seconds (varied)
- Stable performance at 1440p

---

## Engine & Tech

### Engine
- **Godot**

### Architecture Principles
- Scene-based units (`Soldier.tscn`, `Tank.tscn`, etc.)
- Reusable SpriteFrames
- Object pooling for bullets and FX
- Palette swaps via shaders, not duplicated assets

---

The exact layout is flexible; the key point is separating:
- **simulation** (units, targeting, spawns)
- **combat** (damage, projectiles)
- **presentation** (FX, decals, camera)

---

### Scene Graph Overview

**Battlefield.tscn**
- `BattleController` (Node)
- `Units` (Node2D)
  - `TeamAUnits` (Node2D)
  - `TeamBUnits` (Node2D)
- `Projectiles` (Node2D)
- `FX` (Node2D)
- `Decals` (Node2D)
- `Terrain` (TileMapLayer / Node2D)
- `Background` (ParallaxBackground)
- `CameraRig` (Node2D + Camera2D)

Rationale:
- Keeps draw order deterministic (terrain → units → FX → decals optional)
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

#### 2) UnitBase + Subclasses
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


## Non-Goals (For Now)

- No direct player control of individual units
- No complex squad micromanagement
- No full ragdoll physics
- No hyper-detailed UI or RPG systems

---

## Next Milestone (Vertical Slice)

1. One infantry unit
2. One heavy unit (tank or mech)
3. One air unit
4. Two opposing spawn points
5. Core FX stack (muzzle → hit → smoke → decal)
6. Camera, parallax, and screen shake

The goal is to **feel** the battle before expanding systems.

---

