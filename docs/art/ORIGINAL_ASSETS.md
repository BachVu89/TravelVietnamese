# Original pass assets — Blender source and FBX

These assets were authored by the team using deterministic Blender Python geometry, seed `7112026`. No scans, marketplace downloads, reference-image textures, external models or paid libraries were used. They are usable prototype geometry, **not photoreal/scanned assets and not proof of Unreal import, render or mobile performance**.

## Reproduce

From the repository root:

```sh
/usr/bin/blender --background --python scripts/art/create-pass-assets.py
```

Tested with Blender4.3.2. Script clears its own Blender scene, generates original geometry/materials/UV, exports individual FBX files and produces a lineup `.blend` and actual CPU Cycles PNG. It does not modify UE source or acquire dependencies. Cycles denoising is disabled because this installation lacks OpenImageDenoise. Source generation is deterministic; FBX metadata/file hashes may differ across runs or versions.

## Export contract

Files under `unreal/TravelVietnamese/ArtSource/`. Suggested UE destination: `/Game/TravelVietnamese/Original/`. Blender metric unit scale1; FBX `apply_unit_scale=True`, `global_scale=1`, forward−Y/upZ; verify UE centimetre conversion on import against dimensions below. Do not add another arbitrary100× scale without checking FBX unit conversion.

| File / mesh name | Triangles | Dimensions X/Y/Z (metres) | Ordered material slots |
| --- | ---: | --- | --- |
| `SM_CliffRock.fbx` / `SM_CliffRock` | 192 | 3.1678 / 1.8439 / 3.1345 | `M_Cliff_DampStone`, `M_Cliff_Moss` |
| `SM_Fern.fbx` / `SM_Fern` | 1224 | 1.7391 / 1.4580 / 0.9449 | `M_Plant_Stem`, `M_Fern_Leaf` |
| `SM_BananaClump.fbx` / `SM_BananaClump` | 960 | 3.7238 / 2.8767 / 2.4242 | `M_Banana_Trunk`, `M_Plant_Stem`, `M_Banana_Leaf`, `M_Banana_LeafTip` |

Each mesh has origin/base at localZ0, triangulated export and one smart-projected `UVMap` channel. Cliff geometry is irregular multi-ring rock with assigned moss patches. Fern has nine arching fronds with paired lance-shaped leaflets and actual stem geometry. Banana is a three-trunk clump with18 curved, center-folded broad leaves. No sphere-tree substitute is used. Leaf surfaces are thin geometry: use **Two Sided** on imported leaf materials (`M_Fern_Leaf`, `M_Banana_Leaf`, `M_Banana_LeafTip`) if viewing undersides is required; keep opaque shading/no alpha textures. Check imported normals and leaf orientation in UE before acceptance.

Materials are named, opaque Blender Principled color/roughness assignments, not PBR scan maps. Preserve slot assignments and base colors at import; shader translation/roughness/two-sided flags require UE verification. No collision or LOD is claimed: foliage should remain decoration, cliff visual mesh must not silently replace existing gameplay collision. Later mobile optimization may reduce slots/atlas and add LODs after profiling.

`asset-generation-report.json` records names, vertex/triangle counts, slots, dimensions, seed and SHA256 exports. `TV_OriginalPassAssets.blend` contains the lineup scene, lighting, camera and labels, while individual FBX meshes were exported at origin before preview placement. Render-only plane/text/camera/lights are not exported in FBX.

## Evidence and remaining work

`docs/art/asset-preview.png` is an actual Blender4.3.2 CPU Cycles render,20samples,1100×650. Its visible label says “BLENDER PREVIEW - NOT UNREAL”. Designer inspected the output: irregular faceted cliff, fern leaflet structure and curved banana leaves are visible. Render is noisy due to the low sample budget; cliff remains low-poly and colors are illustrative. It is not an Unreal screenshot or a fidelity comparison against the user's reference.

Required next gates: independently inspect exported files, import/cook with pinned UE version, check scale/material slots/two-sided foliage, instantiate as decoration without changing collision, render the scene, then test Android/iOS device budgets. This work does not acquire the proposed Fab/scan libraries or change their unverified licensing status.
