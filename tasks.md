# Tasks: First Milestone - Infantry Battle Visualization

Two infantry units spawn on opposite sides and fight to the death.

---

## Project Foundation

### [x] 1. Create Godot project with resolution settings
### [x] 2. Create Battlefield scene structure
### [x] 3. Implement CameraRig with pixel snapping
### [x] 4. Set up parallax background

---

## Unit System

### [x] 5. Create UnitBase scene and script
### [x] 6. Create HealthComponent
### [x] 7. Create TeamComponent
### [x] 8. Create MovementComponent
### [x] 9. Create TargetingComponent
### [x] 10. Create WeaponComponent (Hitscan)

---

## Infantry Unit

### [x] 11. Create Infantry scene
### [x] 12. Set up infantry SpriteFrames
### [x] 13. Implement infantry behavior loop

---

## Combat & FX

### [x] 14. Implement hitscan damage pipeline
### [x] 15. Create muzzle flash FX
### [x] 16. Create hit spark FX
### [x] 17. Create tracer visual

---

## Battle Flow

### [x] 18. Implement BattleController
### [x] 19. Create spawn points
### [x] 20. Implement battle start sequence

---

## Integration & Polish

### [x] 21. Wire up complete battle loop
### [x] 22. Add minimal debug output
### [x] 23. Basic screen shake on weapon fire

---

## Milestone Complete Criteria

- [x] Two infantry spawn on opposite sides
- [x] They advance toward each other (run_gun animation)
- [x] They stop and shoot when in range (shoot animation)
- [x] Damage is applied, HP decreases
- [x] One unit dies with death animation (die animation)
- [x] Battle detects winner
- [x] Basic FX visible (muzzle spark, hit spark, tracer)
- [x] Parallax background renders correctly
- [x] Runs at 640×360 upscaled to 1440p

---
---

# Tasks: Second Milestone - Tanks & Command Posts

Complete the core game loop with win/lose conditions, introduce tanks for scale variety, and bring the battlefield to life with audio.

---

## Phase 1: Audio System

### [x] 1. Create AudioManager singleton
- Bus layout: Master → SFX, Music, Ambience
- Volume controls per bus
- Polyphony limits to prevent audio saturation

### [x] 2. Implement SFX pooling system
- Pre-instantiate AudioStreamPlayer pools
- Acquire/release pattern for concurrent sounds
- Priority system (weapons > impacts > ambience)

### [x] 3. Add rifle fire sounds
- Multiple sound variations (3-5) for variety
- Randomized pitch shifting (±5-10%)
- Positional audio based on unit location

### [ ] 4. Add bullet impact sounds
- Hit flesh/armor variations
- Miss/terrain impact sounds
- Sync with existing hit spark FX

### [ ] 5. Add death sounds
- Infantry death grunt/cry
- Body fall sound

### [ ] 6. Create battle ambience layer
- Distant gunfire loop
- Environmental sounds (wind, debris)
- Fade in/out with battle state

### [ ] 7. Add background music system
- Combat music track(s)
- Victory/defeat stingers
- Crossfade between states

---

## Phase 2: Command Posts (Win/Lose Condition)

### [ ] 8. Create CommandPost scene
- Large static structure with HP
- Team assignment (A/B)
- Visible health bar or damage state

### [ ] 9. Implement CP health system
- Track damage from all sources
- Broadcast `command_post_destroyed` signal

### [ ] 10. Add CP targeting priority
- Heavy units prioritize CPs when in range
- Infantry ignore CPs (focus on enemy units)

### [ ] 11. Implement battle end detection
- BattleController listens for CP destruction
- Determine winner based on surviving CP

### [ ] 12. Create CP destruction FX
- Large explosion sequence
- Debris particles
- Lingering smoke/fire

### [ ] 13. Add victory/defeat state
- Simple UI text or visual indicator
- Trigger victory/defeat audio stingers

---

## Phase 3: Tank Heavy Unit

### [ ] 14. Create Tank scene
- Heavy unit with all components
- Larger sprite, more HP
- Slower base speed

### [ ] 15. Implement tank movement
- Slow acceleration/deceleration curves
- Inertia-based stopping
- Tread dust FX while moving

### [ ] 16. Create projectile weapon system
- Non-hitscan cannon shells
- Arc trajectory (optional) or straight path
- Travel time before impact

### [ ] 17. Implement ProjectileManager
- Track active projectiles
- Object pooling for shells
- Collision detection and damage application

### [ ] 18. Create tank cannon sounds
- Loud, bass-heavy fire sound
- Shell whistle/travel sound
- Massive impact explosion sound

### [ ] 19. Tank shell impact FX
- Large explosion (use 9-frame explosion asset)
- Strong screen shake
- Debris particles
- Scorch mark decal

### [ ] 20. Add tank targeting logic
- Prefers: Tanks > Command Posts > Infantry
- Longer target acquisition range
- Slower turret tracking (visual only)

---

## Phase 4: Enhanced FX & Polish

### [ ] 21. Implement FxManager singleton
- Central spawn point for all FX
- Category-based caps (explosions, smoke, sparks)
- Priority-based dropping when saturated

### [ ] 22. Create large explosion FX
- Use existing 9-frame explosion asset
- Screen flash on detonation
- Spawn smoke + debris

### [ ] 23. Add smoke puff FX
- Lingering smoke that stacks
- Cap maximum simultaneous smoke
- Slow fade over 2-4 seconds

### [ ] 24. Implement DecalManager
- Scorch marks and craters
- FIFO removal when cap reached
- Slow alpha fade over time

### [ ] 25. Body persistence system
- Corpses remain for 5-10 seconds
- Gradual fade out
- Cap maximum corpses on screen

### [ ] 26. Enhanced screen shake
- Trauma-based accumulation
- Magnitude scaling by event type
- Rifle: tiny, Tank shell: large, CP explosion: massive

---

## Phase 5: Object Pooling & Performance

### [ ] 27. Create generic Pool system
- Pre-warm N instances per type
- Acquire/release interface
- Auto-expand with warning

### [ ] 28. Pool bullets and tracers
- Mandatory for hitscan weapons
- Reset state on acquire

### [ ] 29. Pool FX sprites
- Muzzle flash, sparks, smoke, explosions
- Return to pool on animation_finished

### [ ] 30. Pool audio players
- SFX AudioStreamPlayer instances
- Return on sound completion

### [ ] 31. Implement FX priority caps
- Define max per category
- Drop low-priority FX first when saturated
- Log warnings in debug mode

---

## Phase 6: Multi-Unit Battles

### [ ] 32. Spawn multiple infantry
- 5-10 per side
- Staggered spawn positions
- Slight randomized advance speed

### [ ] 33. Spawn tanks
- 1-2 per side
- Spawn behind infantry line

### [ ] 34. Implement spawn waves
- BattleController manages timed waves
- Configurable wave composition
- Delay between waves

### [ ] 35. Basic army composition
- Pre-battle unit counts (hardcoded for now)
- Infantry count, tank count per side

### [ ] 36. Audio mixing for large battles
- Ensure sounds don't clip or distort
- Duck lower priority sounds
- Maintain clarity of important events

---

## Milestone 2 Complete Criteria

- [ ] Audio system plays weapon, impact, and death sounds
- [ ] Background music and ambience during battle
- [ ] Two Command Posts at battlefield edges
- [ ] Battle ends when a CP is destroyed
- [ ] Victory/defeat state clearly indicated
- [ ] Tanks spawn and fire projectile shells
- [ ] Tank shells cause explosions with screen shake
- [ ] Multiple infantry (5-10) per side
- [ ] 1-2 tanks per side
- [ ] FX pooling prevents performance degradation
- [ ] Smoke and scorch decals accumulate and fade
- [ ] Bodies persist briefly before fading
- [ ] Match feels like a "battle" not a duel
- [ ] Audio layering creates immersive chaos
