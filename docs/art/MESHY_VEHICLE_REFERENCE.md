# Vehicle Reference — actual uploaded asset identification

## Identity: pickup truck, not motorcycle

Designer actually imported the supplied FBX into Blender4.3.2, explicitly bound all four supplied PNG maps and opened two CPU Cycles renders. The model is **one orange expedition pickup truck**, with four road wheels, rear canopy, rear spare tyre, roof rack/bags and side steps. It is neither a motorcycle/moped nor a reference board containing multiple bikes. Do not substitute it for the player motorcycle or claim it supplies motorcycle geometry/rigging.

It can be evaluated as a truck traffic visual or parked prop after separate optimization/import work. This inspection does not apply it to gameplay or claim Unity rendering.

## Ingestion and reproducibility

Downloaded three uploaded parts, in order:

1. `file_0000000037e8820996b4e8cacf5b929a`,25,165,824bytes
2. `file_0000000058848211bb37aa159f19596c`,25,165,824bytes
3. `file_000000002480820987d1f1110c22098c`,16,704,720bytes

Used existing `scripts/art/unpack-meshy-volumes.py --output /tmp/meshy-vehicle-reference PART1 PART2 PART3`. The resulting7z contains one inner ZIP,69,143,604bytes, not loose FBX files. Inner ZIP contains exactly five files: FBX55,112,812bytes and albedo/normal/metallic/roughness PNGs. Join/extraction manifests are `/tmp/meshy-vehicle-reference/parts.json` and `extracted-files.json`; original parts and archive are preserved outside Unity Assets.

Actual inspector run:

```sh
/usr/bin/blender --background --python scripts/art/inspect-meshy-vehicle.py -- --source-zip /tmp/meshy-vehicle-reference/extracted/Meshy_AI_Vietnam_Adventure_Vehicle_Reference_20261108_texture_fbx.zip --output /tmp/meshy-vehicle-inspection
```

CLI also supports `--asset-dir PATH`; default is repository `unity/TravelVietnamese/SourceFiles/Meshy/VehicleReference`, deliberately outside Assets. Folder mode records null archive hash rather than inventing provenance. `--output` defaults `/tmp/meshy-vehicle-inspection`. Original FBX/PNG files are not modified, decimated or re-exported.

Saved evidence: `docs/art/meshy-vehicle-inspection.json`, `meshy-vehicle-front-blender.png`, `meshy-vehicle-reverse-blender.png`. Labels front/reverse name inspection-camera directions, not exact head-on vehicle views. These are actual Blender renders, **not Unity screenshots**.

## Geometry and import contract

| Property | Measured result |
| --- | --- |
| FBX | `Meshy_AI_Vietnam_Adventure_Vehicle_Reference_20261108_texture.fbx` |
| FBX SHA256 | `16d0525690b05d6ad37e3c4600106976a8ed5fc6fe74bc19738a33f3588efb30` |
| Mesh | One object `Mesh_0` |
| Vertices / triangles | 576,601 / **1,153,926** |
| UV / material slot | One `UVMap`; one **`Material.001`** |
| Armatures, bones, actions | None |
| Vertex groups, shape keys, modifiers | None |
| Object location/scale | Zero /1; near-zero rotation after FBX conversion |
| DimensionsXYZ | 1.900251 ×0.637074 ×0.789692 Blender importer world units |
| Min boundsXYZ | −0.950661, −0.318001, −0.396911 |
| Max boundsXYZ | +0.949590, +0.319073, +0.392781 |
| Facing | Visually front bumper approximately **Blender−X**, rear spare/canopy towards+X, up+Z |
| Pivot | Near centre, not wheel-contact ground |

Wheels, body, bags and accessories are not separate object/rig parts. No wheel bones, suspension animation, steering rig or existing physics is supplied. Whole-vehicle motion as a static traffic visual is possible in principle; spinning/steering wheels requires segmentation/rigging work or a separate model. Do not claim real vehicle physics because the mesh has visible wheels.

Axis/bounds must be verified after Unity conversion. Normalize to an explicitly chosen truck length using actual Renderer bounds, then shift its wrapper to wheel-contact ground; source units do not prove a1.9m full-size pickup. A motorcycle-sized target height would produce wrong proportions. Keep collision as a separate simple gameplay shape rather than using this1.154million-triangle source as collision.

## Materials and visual observations

Four supplied maps are2048×2048. Basecolor is sRGB; metallic, roughness and tangent normal are data/non-color. Remap `Material.001` to explicit PNGs rather than relying on FBX `.fbm` references. Unity smoothness needs an inverted roughness value/packed derivative as required by the chosen shader. Normal green-channel convention is not declared; verify a lit panel/dent before deciding to flip. No AO, height, LOD, collision, rig or animation asset is provided.

The two inspected views show a recognizable detailed truck silhouette with readable body panels, mud, wheels, roof bags and rear spare. Windows look dark/opaque; no interior is established. Some generated detail/straps and panel seams may be fused or inaccurate close-up; no manufacturer/model or branding rights are inferred. No large missing body part or open hole was apparent in these views, but this is not a manifold/self-intersection audit. Steering/wheel mechanisms remain fused visual geometry.

Density is high for mobile traffic: source alone is1,153,926triangles. Preserve it outside Assets; derive separately reviewed low/mid LOD meshes before repeated traffic instancing. No derivative or performance validation is claimed by this inspection. A detailed source render does not prove the whole scene has achieved photoreal quality.

## Provenance and next gates

Provenance is user-provided Meshy export; no license file is present among the five inputs. Record that fact without inventing license terms or blocking the authorized local integration flow. No marketplace download or scan claim is made.

Root can decide whether to use this as optimized truck traffic/prop. Remaining gates: LOD derivative, actual Unity import/material/axis/ground alignment, collider integration, scene render and OppoFindX7Ultra/iPhone13 profiling. Player-motorbike asset availability is a separate issue; this upload does not resolve it.
