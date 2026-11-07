# Original forest geometry for Unity art iteration

Generator: `scripts/art/create-unity-forest-assets.py`, tested using `/usr/bin/blender`4.3.2:

```sh
/usr/bin/blender --background --python scripts/art/create-unity-forest-assets.py
```

Outputs: `unity/TravelVietnamese/Assets/TravelVietnamese/Art/ForestSource/` contains `SM_BroadleafTree.fbx`, `SM_PineTree.fbx`, `SM_ForestBush.fbx` and `forest-generation-report.json` with triangle counts/dimensions/material slots/SHA256. The fixed seed is71130. All geometry/material colors are original procedural work; no scans, marketplace assets, texture downloads, reference-image textures or branded species claims.

## Shapes and importer contract

- **Broadleaf:** bent tapered trunk,12 scaffold branches, divided twigs, individually folded opaque leaves with clustered tip fans. No sphere canopy. Uses bark and three foliage colors.
- **Pine:** tapered trunk and8 irregularly rotated branch whorls, split boughs with jagged needle-fan geometry. No stacked solid cones. Uses bark and dark needle color.
- **Bush:**11 divided woody stems with multiple leaf fans; small irregular silhouette, no ellipsoid globe.

Meshes are triangulated, local baseZ0 in Blender, one smart-projected UVMap channel. Scene unit metric1, export global_scale1/apply_unit_scale=True, FBX forward−Z/upY for Unity. Verify Unity importer scale/dimensions before placement; do not blindly add100× scale. Report dimensions are Blender XYZ metres; heightZ maps to UnityY after conversion.

Named slots are stable: `M_Forest_Bark`, `M_Forest_LeafDeep`, `M_Forest_LeafMid`, `M_Forest_LeafSun`, `M_Forest_PineNeedles`. Materials are opaque color/roughness assignments; no alpha textures. Leaf front/back surfaces are explicit folded triangles, so foliage does not require an alpha blending shader. The mesh slot list includes unused palette slots for a consistent importer API; importer may prune unused slots or atlas materials after validation. Preserve named assignments rather than tinting every surface the same green.

These are near/midground prototype assets, not a full forest to instantiate unboundedly. Use mesh reuse/instancing, density limits, distance culling and lower-detail geometry at distance. Per-leaf double surfaces cost triangles; an art review is not proof of mobile optimization. Keep foliage decorative: do not change road/POI/traffic collision when replacing forest meshes. No LOD, rig, wind animation, collision or device performance claim is made by this generator.

## Actual evidence and limitations

`docs/art/forest-preview.png` is an actual Blender CPU Cycles render,24samples,1200×850. Its label explicitly identifies Blender, not Unity. Designer inspected the first output and found broadleaf foliage too sparse and framing clipped; the generator was revised to enlarge leaves/add tip fans, increase pine fan area and widen the camera before final export. This is geometry iteration, not merely recoloring sphere trees.

The foliage remains stylized/faceted, with triangular leaves and visible repeated branching rules. Bark is a simple assigned material, not scan/PBR texture. Preview has low-sample noise. It is not a Unity screenshot, reference-fidelity acceptance, photoreal demonstration, runtime forest density test or mobile benchmark. Root must verify actual Unity mesh import/materials, scene composition and gameplay camera rendering; QA independently reads back exports. OppoFindX7Ultra/iPhone13 performance remains a separate gate.

Do not modify or infer licensing changes to the earlier Unreal cliff/fern/banana exports: this forest batch has separate source/export paths.

Authoring `.blend` source is stored at `art-source/unity/ForestSource/TV_OriginalForest.blend`, outside Unity Assets so the project does not attempt Blender-dependent model import. FBX/provenance remain in `Assets/TravelVietnamese/Art/ForestSource`. Leaf geometry includes front/back surfaces separated by 2 mm; the V3 palette retains back-face culling to avoid drawing both shells twice.
