# Meshy Expedition Courier — actual asset inspection

## Source and reproducible inspection

Source is the user-provided three-part archive, joined/extracted by root into `/tmp/meshy-courier/extracted`. This inspection reads only the five extracted courier files: one FBX and four PNGs. It does not read or assess the separate moped archive. No license file is present among these five files; record provenance as **user-provided Meshy export**, without inferring particular commercial rights or blocking the authorized local integration workflow.

Generator/inspector:

```sh
/usr/bin/blender --background --python scripts/art/inspect-meshy-courier.py -- --asset-dir /tmp/meshy-courier/extracted --output /tmp/meshy-courier-inspection
```

Default `--asset-dir` is repository `unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/Courier`; `--output` defaults `/tmp/meshy-courier-inspection`. Optional `--source-zip PATH` supports a conventional ZIP input, not joining7z parts. Folder input records null ZIP/hash, with per-file hashes instead. Original files are preserved; copies and review renders are made in the output directory. No decimation, rigging, pose change or source re-export is performed.

Actually run with Blender4.3.2. Saved evidence:

- `docs/art/meshy-courier-inspection.json`
- `docs/art/meshy-courier-front-blender.png`
- `docs/art/meshy-courier-reverse-blender.png`

Designer opened both actual CPU Cycles renders with the four explicitly bound PNG maps. They are **Blender inspection images**, not Unity/Unreal renders or a whole-game fidelity gate.

## Findings that constrain integration

| Item | Actual result |
| --- | --- |
| Source FBX | `Meshy_AI_Expedition_Courier_20261108_texture.fbx`,55,385,228bytes |
| FBX SHA256 | `89280dc55f1e551fca843548dd92aa1e65dce731c6f4446f41e36806686e2278` |
| Mesh | One `Mesh_0` |
| Vertices / triangles | 573,861 / **1,148,034** |
| UV / material | One `UVMap`; one slot **`Material.001`** |
| Armatures / bones / actions | None / none / none |
| Vertex groups / shape keys | None / none |
| Modifiers / armature bindings | None / none |
| Object transform | Location0, scale1; X rotation approximately−4.37e−8rad after conversion |
| Bounds minXYZ | −0.627401, −0.295172, −0.951083 |
| Bounds maxXYZ | +0.628675, +0.303740, +0.949602 |
| DimensionsXYZ | 1.256076 ×0.598912 ×1.900685 Blender importer world units |
| Pivot | Around vertical centre, not feet/base |

**It is a static standing A-pose character.** Arms slope outward/down; knees/legs are standing, hands are not at handlebars. It is not a rigged rider, a seated pose or an animated walking model. No supplied bone weights/skeleton/animation can be applied merely by changing Unity importer to Humanoid. Do not attach the standing mesh to a motorbike and report a valid seated rider. Rigging/retopology/weighting and animation are separate work, or it can be clearly shown as a static preview/NPC pending that work.

1.148million triangles is a high-density source, not a mobile-ready character. Do not use many copies or claim performance readiness. Preserve original; any decimated/retopologized mesh must be a separate derivative with UV/appearance comparisons. No derivative is produced by this inspection. A collider should be a separate simple gameplay volume, not this detailed triangle mesh.

## Facing, placement and visible content

Camera from Blender direction approximately(1,−3,+1) sees the face, jacket front and hanging camera. Opposite camera(−1,+3,+0.8) sees the backpack and bedroll. Thus the **visual front is approximately Blender−Y; backpack is +Y; upright is +Z**. This is geometry-based inspection, not a guarantee of final Unity imported axes. Verify the imported wrapper facing and up-axis before rotating/placing in game.

Normalize target height from actual Unity Renderer bounds, not assumptions about exporter centimetres. Source feet/base lie about0.951083 below the pivot in Blender units. Root may use a wrapper with uniform scale/base translation while keeping the original FBX intact. Clothing/backpack/camera are fused into the same static object and material, not separately rigged accessories.

Both images show a recognizable face, helmet/goggles, olive jacket, gloves/hands, dark trousers/boots, backpack and rolled gear. This is a substantial visual-detail increase over the earlier box/capsule mannequin. Fine facial/finger detail remains AI-generated and should be reviewed close-up; accessory straps/pouches can have blended forms. Hands are visible but topology/deformation quality is unverified. No large missing body part or obvious open hole was apparent from the two views, but those views are not a manifold/self-intersection audit. Back-of-helmet highlight is strong in this inspection lighting, so verify wetness/smoothness under game lighting rather than copying the render exposure.

## PBR maps and limitations

All four supplied maps are2048×2048. Bind the explicit `_texture.png` basecolor in sRGB and `_texture_normal.png`, `_texture_roughness.png`, `_texture_metallic.png` as data/non-color. FBX `Material.001` references embedded/extracted `.fbm/Image_0.jpg`, `.fbm/Image_2.jpg` and maps; the Unity material remap should use the supplied PNGs, not rely on those generated paths.

Normal is reviewed via a Blender NormalMap node; archive does not declare tangent normal green-channel convention, so test under actual Unity lighting before deciding to flip. For Unity Lit, convert roughness to the expected smoothness/packed channel in a separate derivative; do not plug roughness directly into smoothness or overwrite original PNGs. No AO, height, animation, skeleton, collision or LOD asset is supplied.

Remaining gates: Unity source import/remap/scale/facing, static-preview placement or explicitly scoped rigging, mobile mesh/texture optimization, actual game render and device profiling. None are established by this Blender inspection. Milestone and courier are distinct inspected assets; moped remains uninspected here.
