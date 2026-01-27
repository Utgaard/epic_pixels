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
