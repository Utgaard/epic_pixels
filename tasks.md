# Tasks: First Milestone - Infantry Battle Visualization

Two infantry units spawn on opposite sides and fight to the death.

---

## Project Foundation

### [ ] 1. Create Godot project with resolution settings
- Create new Godot 4.x project
- Configure display: 640×360 internal resolution
- Configure 4× integer upscale to 2560×1440
- Set nearest-neighbor filtering (no texture smoothing)
- Set up folder structure: `scenes/`, `scripts/`, `resources/`
- Import assets from `assets/` folder

### [ ] 2. Create Battlefield scene structure
Based on GDD scene graph:
```
Battlefield.tscn
├── BattleController (Node)
├── SimRoot (Node2D)
│   ├── Units (Node2D)
│   └── Projectiles (Node2D)
├── RenderRoot (Node2D)
│   ├── Sprites (Node2D)
│   ├── FX (Node2D)
│   └── Decals (Node2D)
├── Terrain (Node2D)
├── Background (ParallaxBackground)
└── CameraRig (Node2D)
    └── Camera2D
```

### [ ] 3. Implement CameraRig with pixel snapping
- Camera2D centered on battlefield
- Pixel-snapped positioning
- Static horizontal framing (no panning for now)
- Placeholder for trauma-based screen shake (implement later)

### [ ] 4. Set up parallax background
Use Mountain Dusk assets (`assets/backgrounds/mountain_dusk/`):
- Layer 1: `sky.png` (static, no parallax)
- Layer 2: `far-clouds.png` (0.1 parallax)
- Layer 3: `far-mountains.png` (0.2 parallax)
- Layer 4: `near-clouds.png` (0.3 parallax)
- Layer 5: `mountains.png` (0.5 parallax)
- Layer 6: `trees.png` (0.8 parallax, foreground)
- Establish ground level Y coordinate for infantry lane

---

## Unit System

### [ ] 5. Create UnitBase scene and script
Core unit foundation:
- Team ID (enum: TEAM_A, TEAM_B)
- HP tracking
- State machine (IDLE, ADVANCING, ATTACKING, DYING, DEAD)
- Reference slots for components
- Signal: `died(unit)`

### [ ] 6. Create HealthComponent
- `max_hp` and `current_hp`
- `take_damage(amount)` method
- Signal: `health_depleted`
- Connect to UnitBase death handling

### [ ] 7. Create TeamComponent
- Store team ID
- Helper: `is_enemy(other_team)` check
- Team color modulation (tint sprite for Team B)

### [ ] 8. Create MovementComponent
- Lane-based forward advance (move toward enemy side)
- Acceleration/deceleration with inertia per GDD
- Stop when in weapon range of target
- Use CharacterBody2D for deterministic movement

### [ ] 9. Create TargetingComponent
- Find nearest valid enemy in same lane
- Periodic evaluation (every 0.25-0.5s, not per frame)
- Signal: `target_acquired(target)`
- Signal: `target_lost`

### [ ] 10. Create WeaponComponent (Hitscan)
- Fire rate, range, damage from config
- Hitscan raycast on fire
- Cooldown tracking
- Signal: `fired(from_pos, to_pos)` for FX

---

## Infantry Unit

### [ ] 11. Create Infantry scene
- Extends UnitBase
- CharacterBody2D root
- Attach all components (Health, Team, Movement, Targeting, Weapon)
- AnimatedSprite2D for visuals
- CollisionShape2D for hitbox

### [ ] 12. Set up infantry SpriteFrames
Create SpriteFrames resource using Space Marine assets (`assets/sprites/infantry/`):
- `idle_gun`: 4 frames from `Idle Gun/sprites/`
- `run_gun`: 10 frames from `Run with Gun/sprites/`
- `shoot`: 2 frames from `Shoot/sprites/`
- `die`: 3 frames from `Die/sprites/`
- Configure frame rates (~10 fps for run, faster for shoot)
- Flip sprites horizontally for Team B (facing left)

### [ ] 13. Implement infantry behavior loop
State machine flow:
1. IDLE → ADVANCING (on battle start)
2. ADVANCING: Play `run_gun`, move forward, run targeting
3. When target acquired and in range → ATTACKING
4. ATTACKING: Play `shoot`, fire weapon, re-evaluate target
5. On health depleted → DYING
6. DYING: Play `die` animation → DEAD
7. DEAD: Disable, persist briefly, then queue_free or hide

---

## Combat & FX

### [ ] 14. Implement hitscan damage pipeline
- Weapon fires → raycast or direct distance check
- On hit: target.health_component.take_damage(amount)
- Emit signal for FX spawning

### [ ] 15. Create muzzle flash FX
Use spark assets (`assets/sprites/fx/spark/Sprites/`):
- 5-frame animated sprite
- Very short duration (~0.1s)
- Spawn at weapon muzzle position
- Pool-ready structure

### [ ] 16. Create hit spark FX
Use hit assets (`assets/sprites/fx/Hit/Sprites/`):
- 3-frame animated sprite (hit1.png → hit3.png)
- Brief duration (~0.15s)
- Spawn at target position on hit

### [ ] 17. Create tracer visual
Use bullet assets (`assets/sprites/infantry/Misc/`):
- `bullet1.png` or `bullet2.png` as tracer
- Stretched/positioned from shooter to target
- Very brief duration (~0.05s)
- Alternative: simple Line2D

---

## Battle Flow

### [ ] 18. Implement BattleController
- Spawn units at battle start
- Track living units per team
- Detect win condition (one team has no units left)
- Signal: `battle_ended(winning_team)`

### [ ] 19. Create spawn points
- Left side spawn for Team A (facing right)
- Right side spawn for Team B (facing left, sprite flipped)
- For milestone: spawn exactly 1 infantry per side

### [ ] 20. Implement battle start sequence
- Initialize battlefield
- Spawn units
- Signal units to begin advancing
- (No pre-battle UI for this milestone)

---

## Integration & Polish

### [ ] 21. Wire up complete battle loop
- Press play → battle starts → units spawn → units fight → one dies → battle ends
- Verify all signals connect properly
- Test multiple runs for stability

### [ ] 22. Add minimal debug output
- Print battle state changes
- Print damage events
- Print battle result

### [ ] 23. Basic screen shake on weapon fire
- Small trauma amount per shot
- Implement trauma decay
- Shake camera offset based on trauma

---

## Milestone Complete Criteria

- [ ] Two infantry spawn on opposite sides
- [ ] They advance toward each other (run_gun animation)
- [ ] They stop and shoot when in range (shoot animation)
- [ ] Damage is applied, HP decreases
- [ ] One unit dies with death animation (die animation)
- [ ] Battle detects winner
- [ ] Basic FX visible (muzzle spark, hit spark, tracer)
- [ ] Parallax background renders correctly
- [ ] Runs at 640×360 upscaled to 1440p
