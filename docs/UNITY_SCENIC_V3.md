# Scenic V3 — scene structure, forest and vehicle art

This batch addresses the user's second Unity screenshot: flat texture-covered slopes, empty valley, sparse plants, block rider/bike and large desktop controls. It is a source/art update, **not a Unity render or visual acceptance result**.

## Apply to the existing scene

1. Stop Play, save/commit local changes and update `codex-work` without reset/clean.
2. Reopen `unity/TravelVietnamese` and wait for imports/compilation. Open `PassDemo`.
3. Choose **TravelVietnamese → Update Scene Graphics** (now applies Scenic V3), or **Apply Scenic V3**.
4. Ctrl+S, then Play. Inspector `PassGame` should have `Scenic Quality` checked and references for Broadleaf/Pine/Bush/Bike/Rider/Walker prefabs. A successful menu writes `SCENIC_V3_ASSIGNED` to Console.

Do not delete the scene or Generated assets. New assets live under `Generated/ScenicV3`; old material files remain. Import-by-source-material-name also writes remaps to the **new forest/travel FBX importers**: these can affect any other use of the same FBX. Undo of scene fields alone is not a full rollback of importer metadata, generated assets or sky/ambient changes. Preserve scene and `.meta` files before applying.

## Visible changes intended by the source

- Replaces the two old flat decorative slope strips with 30 ridged grid chunks and three 3D distant ridge silhouettes. Core road/shoulder collision strips and gameplay progression remain the same.
- Uses original branched broadleaf/pine/bush models with chunked GPU instancing and distance culling. The batch cap is 1,020 tree and 380 understory placements; this is **not FPS or mobile optimization proof**. Trees are 6,958–7,808 triangles each; further LOD work and real profiling remain necessary.
- New original touring bike, seated backpack rider and standing explorer replace block silhouettes when assigned. No rig/animation is claimed.
- Lowers exaggerated repeating wet-road highlights; adds an overcast procedural sky/ambient setup for URP. HDRP still needs its own valid Volume/lighting setup.
- Desktop has a compact HUD/footer and hides simulated joystick/pedal panels; mobile/ForceTouchControls retains touch panels and action sizes.

The old very-wide valley parameter folded the generated ribbon at some bends. Numerical source-equation audit found and corrected the fold by bounding lateral extent; this is not a Unity renderer test. Decorative terrain is also kept below the flat stopping bay so ridges do not cover the playable pad.

## Evidence and remaining gaps

[Forest assets](art/FOREST_ASSETS.md), [vehicle/characters](art/TRAVEL_ASSETS.md), [validation](UNITY_VALIDATION.md). Actual Blender renders were inspected and FBX files independently read back. These confirm authored geometry, not Unity shader/import/render parity.

Asset quality remains stylized; no scan assets, licensed Asset Store environment, animation library or measured photoreal match was acquired. Unity import, orientation/scale, instanced shadows, clipping, screenshot composition, memory/frame time/temperature on Android/iOS need actual engine/device review. Do not treat logic-test counts as an art score.
