# Supplied Meshy asset library

Six groups have been inspected. Original split archives/source FBXs are retained in the workspace library/staging; original PBR PNGs and derived static FBX LODs are prepared for Unity. Raw 300+ MB environment FBXs are not copied into `Assets`.

| Group | Actual source | Use in this update |
| --- | --- | --- |
| Weathered Đà Lạt Milestone | 151,018 triangles; single textured milestone | POI visual, normalized to 1.4 m; existing collider/IDs retained |
| Expedition Courier | 1,148,034 triangles; unrigged A-pose character | Static review prefab, 1.75 m; not a seated/animated player |
| Urban Explorer | 1,126,822 triangles; a different unrigged A-pose character | Alternative static character review, 1.75 m |
| Vietnam Adventure Vehicle Reference | 1,153,926 triangles; orange pickup with fused wheels | Static pickup review, 2 m high; **not a motorcycle replacement** |
| Floating Fern Terraces | 7,735,978 triangles; rectangular soil/rock/fern ground patch | Derived LODs; exactly eight bounded decorative patches outside the playable road/bays |
| Mountain Jungle | 7,746,512 triangles; three volumetric diorama chunks fused into one object | Composite review only; separate chunks before any terrain replacement |

The original Rusty Courier Moped ZIP is still unavailable through the 32 MiB single-file transfer. The newly received Vehicle Reference is a pickup, not that moped. No license documents were present in inspected packages; provenance records user-supplied Meshy exports without inventing CC0 or library licenses.

## Apply and review

1. Stop Play, preserve local scene/material/meta edits, update `codex-work`, then wait for Unity import/compile.
2. Open your existing `PassDemo`, choose **TravelVietnamese → Apply Meshy Assets**, then Ctrl+S.
3. Play: source adds the actual PBR milestone at both POIs and eight fern patches around the stops when ScenicQuality is enabled. Existing IDs, cylinders' collision, movement and journal are unchanged. Ferns use a separate decorative transform aligned to the terrain; child colliders are disabled. Their initial LODs are not forced.
4. Choose **TravelVietnamese → Review Meshy Assets** to open a separate **unsaved static gallery** of the six assets. Save/discard the current scene only as intended when Unity prompts. Gallery instances force LOD0 for inspection; this is not a game performance test. PassDemo is not overwritten.
5. **Select Prepared Meshy Prefabs** selects the generated assets in Project. Output paths are in `Assets/TravelVietnamese/Art/Imported/Meshy/catalog.json`; LOD families use `Generated/Meshy<Family>/Preview.prefab`.

Only milestone and bounded fern decoration are assigned by Apply. Characters remain unrigged; no bones, weights, walking or seated poses are fabricated. Pickup wheels are fused and no vehicle simulation has been produced. Jungle remains a three-chunk composite; it is not a continuous Vietnam landscape or a tree kit.

The gallery uses intended front-facing orientations from the Blender inspection; actual Unity axis conversion and scale still require review. `Milestone Yaw Offset` is adjustable if the lettering faces away from the road.

## Geometry and textures

- `lod-provenance.json` records actual exported vertex/triangle counts and hashes. Targets are approximate: disconnected foliage may stop above the requested triangle count. Do not label a 50k target as a 50k result.
- Courier LOD0/LOD1 have 99,998/30,000 triangles; Urban and pickup have 80,000/20,000. Fern version 2 exports 600,000/300,000 triangles (independent FBX readback 599,998/299,998); Jungle exports/readbacks 200,000/50,000. The first fern reduction (about 200k/98k) was visually rejected and is not the shipped geometry. The higher-detail retry passed the inspected Blender silhouette/soil-continuity views, not Unity or device acceptance. These reductions do not prove mobile performance, UV fidelity or animation readiness.
- Source albedo is sRGB; normal is NormalMap/linear; metallic/roughness are linear. `pack-meshy-mask.py` makes RGBA: R=metallic, G=255 (no AO supplied), B=128, A=255−roughness. Independent full-pixel checks validate packing, not Unity compression or shader behavior.
- Original PNG bytes remain unchanged. Derived geometry does not overwrite original FBX files. Imports write `.meta` settings and new generated materials/prefabs; edits to already-generated outputs are preserved.
- Original sources are retained under `/workspace/library-files/meshy-originals/` and the staging paths recorded in each intake report. Recreate with `blender --background --factory-startup --python scripts/art/prepare-meshy-courier.py -- --source-dir <original-folder> --output-dir <derived-folder> --asset-prefix <family> --lod0-triangles <count> --lod1-triangles <count>`. Preserve artist edits before regeneration.

Actual Blender inspections/readbacks and derived previews were performed. They are **not Unity screenshots, successful Editor compilation, physics/rig tests or Android/iOS benchmarks**. Rigging, LOD popping, normal orientation, asset placement and phone budgets remain real-engine gates. No new APK is claimed.

## Source inspections

[Milestone](art/MESHY_MILESTONE.md) · [Courier](art/MESHY_COURIER.md) · [Urban](art/MESHY_URBAN_EXPLORER.md) · [Pickup](art/MESHY_VEHICLE_REFERENCE.md) · [Fern patch](art/MESHY_FERN_TERRACES.md) · [Jungle](art/MESHY_MOUNTAIN_JUNGLE.md) · [QA evidence](UNITY_VALIDATION.md).

## Visual review outcomes

[Derived review](art/MESHY_DERIVED_REVIEW.md) records both the rejected first fern reduction and the visually improved version 2. Low truck detail is only a candidate for distant traffic: body/window warping remains visible. Jungle remains a composite with visible base walls/gaps. No character is accepted as animated and no asset is declared phone-optimized from a triangle count. The explicit Apply menu selects the reviewed fern retry for eight decorative instances; this adds a real geometry cost and needs Unity frame-time/LOD-distance testing before mobile release.
