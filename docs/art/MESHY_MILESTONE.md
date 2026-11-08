# User-supplied Meshy milestone — actual inspection

## Input and scope

Inspected only the user-uploaded `Meshy_AI_Weathered_Đà_Lạt_Milestone_20261108_texture_fbx.zip`, attachment `0d145693-ca91-4caf-b0ef-68ac766a26ff`. ZIP SHA256: `da82ae8b75e7eeffbc032f970d8595d8ee6e3af03cd1c24adecfef9fedf7be98`.

This ZIP contains exactly five files: one FBX and albedo/metallic/normal/roughness PNGs. No license/attribution file is present. Provenance is **user-provided Meshy export**; no particular commercial license or source-scan claim is inferred. Record this fact without blocking the authorized local integration workflow. Character and moped archives were not read or inspected here; no claims about their geometry, textures, rigs or usability are made.

Original files are preserved. Inspection extracted copies only under `/tmp/meshy-milestone-inspection/`; it does not re-export, decimate, overwrite or normalize the uploaded model. Root imports the original named files separately into Unity's `Art/Imported/Meshy/Milestone` path.

## Reproduce and evidence

```sh
/usr/bin/blender --background --python scripts/art/inspect-meshy-milestone.py -- --asset-dir unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/Milestone --output /tmp/meshy-milestone-inspection
```

For the original archive, pass `--source-zip PATH` instead of `--asset-dir`. Default asset directory is the repository imported milestone directory, and default output is `/tmp/meshy-milestone-inspection`. Folder inspections record a null ZIP/hash instead of inventing archive provenance. Actually run with Blender4.3.2. The script validates ZIP paths/file types, imports the FBX, records mesh/material/UV/animation metadata, explicitly reconnects the four supplied maps for review, then makes two CPU Cycles renders. Results:

- `/tmp/meshy-milestone-inspection/report.json` — measured data, per-file hashes and map assignments.
- `/tmp/meshy-milestone-inspection/front-blender.png`
- `/tmp/meshy-milestone-inspection/reverse-blender.png`

Designer opened both renders with the image viewer. These are actual **Blender inspection renders**, not Unity/Unreal screenshots or a device-performance/fidelity gate. “Front/reverse” are inspection-camera labels; visible lettering identifies the front face.

## Measured source geometry

| Item | Measured result |
| --- | --- |
| Mesh | One object, `Mesh_0` |
| Vertices / triangles | 75,509 / **151,018** |
| Polygons | 151,018 triangles |
| UV | One `UVMap` |
| Material slots | One, `Material.001` |
| Armatures / animation actions | None / none |
| Modifiers | None |
| Object transform | Position0, scale1; near-zero X rotation from FBX conversion |
| World bounds XYZ | Min −0.500950, −0.313377, −0.950432; max0.511018,0.319841,0.949609 |
| Dimensions XYZ | 1.011968 ×0.633218 ×1.900041 Blender world units after import |
| Pivot | Near center vertically, **not base pivot** |

These dimensions describe importer output, not verified real-world centimetres. Unity wrapper target height1.2m should be computed from actual imported Renderer bounds. If those bounds match Blender, uniform scale≈0.631565 and base translation≈+0.60026m place bottom atZ0 before Unity axis conversion. Do not hard-code that offset without checking final wrapper orientation/bounds. Keep original mesh unmodified; wrapper placement should not add a new collider over gameplay collision.

151k triangles is excessive for many small repeated mobile roadside props. Suggested later **derived** LOD candidates are approximately20k/5k/1k triangles plus culling, subject to retaining silhouette/UV/lettering and comparing renders. These are proposals, not exported LODs or evidence that decimation passed. Never decimate or replace the preserved original without a distinct output path. Use simple existing gameplay collision rather than a151k-triangle mesh collider.

## Maps and import guidance

All four PNGs are2048×2048. Albedo is RGB/sRGB. Normal is RGB data; roughness and metallic are grayscale data. Explicit map assignments were used because FBX material nodes reference `.fbm/Image_0.jpg`, `.fbm/Image_2.jpg` and other embedded/extracted paths, which should not be trusted as the final Unity map hookup.

| Map | Review assignment / Unity guidance |
| --- | --- |
| `_texture.png` | Base Color, sRGB enabled; do not tint over the red/white/lettering |
| `_texture_normal.png` | Tangent-space normal via normal-map node; Unity TextureTypeNormalMap. Green-channel convention is not declared by archive, so test a lit dent/edge before deciding to flip. |
| `_texture_metallic.png` | Non-color/data, nearly black on average0.02/255; concrete should remain essentially nonmetallic. |
| `_texture_roughness.png` | Non-color/data, measured values106–207/255 (mean169.17); Unity Lit smoothness requires inversion/packing into the pipeline's expected channel, not plugging roughness straight into smoothness. |

No AO, height/displacement, emission, opacity, collision or LOD file is supplied. Do not infer missing maps or rig support. Existing texture data must not be recomputed destructively on the original PNGs. A separate packed metallic/smoothness derivative can be made by the importer with provenance.

## Visual review and remaining issues

The front render has recognizable black **“ĐÀ LẠT” / “KHÁNH LÊ”** lettering, red rounded cap, white concrete body and a broad base. Chipped paint, cracks, dirt and moss are visible. Rear face has no lettering and is heavily weathered. This is a substantial prop-detail improvement over a blank primitive milestone, but it does not prove the whole scene looks realistic.

The generated weathering/base includes sculpted lumpy/rust-brown regions that may look melted or overly eroded close up; inspect at intended camera distance. Lettering is baked into albedo/geometry appearance, not editable text or verified official signage. No major hole was apparent in the two review views, but this is not a full manifold/topology audit. Normal maps render plausibly in Blender; Unity still needs actual lighting/material verification.

Next gates: verify Unity scale/base alignment and supplied-map hookups, retain no-collider wrapper contract, capture actual in-scene front/side views, evaluate texture compression and derived LODs, then profile on OppoFindX7Ultra/iPhone13. No Unity render, Android/iOS performance, acquired license or character/moped readiness is claimed here.

Saved review copies: `docs/art/meshy-milestone-front-blender.png`, `meshy-milestone-reverse-blender.png`, `meshy-milestone-inspection.json`. The script was also rerun successfully against the repository asset directory; folder mode correctly reports null ZIP provenance and the same151,018-triangle mesh.
