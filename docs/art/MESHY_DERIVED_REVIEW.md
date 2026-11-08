# Meshy derivatives — actual Blender visual acceptance review

This review explicitly selects each derived FBX with `--fbx-name`; it does not pick an arbitrary file from a folder containing several LODs. Original FBX and PNG maps are unchanged. Blender4.3.2 actually imported/rendered each mesh with supplied albedo/normal/metallic/roughness, CPU Cycles20samples. Designer opened both angles for all three assets and compared fern against the saved source render. These are **Blender inspection images, not Unity/gameplay renders or performance benchmarks**.

## Reproduction

Run from repository root:

```sh
blender --background --python scripts/art/inspect-meshy-courier.py -- --asset-dir unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/FernTerraces --fbx-name FernTerraces_LOD1.fbx --output /tmp/meshylowfern
blender --background --python scripts/art/inspect-meshy-courier.py -- --asset-dir unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/MountainJungle --fbx-name MountainJungle_LOD0.fbx --output /tmp/meshylowjungle
blender --background --python scripts/art/inspect-meshy-courier.py -- --asset-dir unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/VehicleReference --fbx-name VehicleReference_LOD1.fbx --output /tmp/meshylowvehicle
```

Saved evidence under `docs/art/`: `meshy-derived-{fern-lod1,jungle-lod0,vehicle-lod1}-{front-blender.png,reverse-blender.png,report.json}`. Reports record actual selected mesh/counts/materials/map resolution. Imported triangles measured **98,107** for fernLOD1, **200,000** for jungleLOD0, **20,000** for vehicleLOD1. Fern was described upstream as about98,110 after collapse constraints; the imported FBX measurement here is98,107, not the original target50,000. Triangle target alone does not mean a derivative is visually acceptable.

## FernTerraces_LOD1 — reject for near-ground use

The derivative still reads as one rectangular fern/rock/soil patch, but close-view quality loss is **severe**. Fine fronds have collapsed into pointed shards, grass/leaf silhouettes become spikes, smooth rocks become angular folded fans, and the front/rear exposed soil base has large stretched triangles. The reverse view makes these defects especially clear. Compared to the saved source view, fern shape and small rock/soil continuity are substantially degraded.

**Decision:** do not accept this LOD as a close roadside groundpatch or near-POI decoration. It may only be considered for distant, small screen coverage after an actual gameplay-distance test; no distance threshold has been validated here. Retain higher-detail LOD or create a better derivative with protected silhouette/UV/seams, selective plant/ground simplification and normal-map baking. No mesh repair or new derivative was performed by this review. Do not hide rejection behind the fact that the file imports or has fewer triangles.

## MountainJungle_LOD0 — three diorama chunks remain

Both views clearly retain **three separate forest-on-base diorama chunks**: a long centre strip, another cluster to one side and a smaller patch. They are not one standalone tree, not a continuous forest terrain and not a playable road environment. Tree trunks/crowns and mixed forest silhouettes remain recognizable at the presented full-asset scale. Crowns are lumpy/merged at small detail; flat gray cut base walls and open gaps between chunks are obvious. Individual leaf fidelity is not demonstrated.

**Decision:** conditionally usable as a distant/background diorama source if bases/gaps are intentionally concealed by surrounding terrain and the actual placement is reviewed. Do not scatter the entire combined model as if it were a single tree or assume it replaces all near forest. No close-canopy fidelity acceptance, individual-tree extraction, collision/terrain integration or mobile performance acceptance is made. Need actual Unity placement/render before calling the scene improved.

## VehicleReference_LOD1 — silhouette retained, panel damage visible

The20k derivative retains a recognizable orange pickup silhouette, four road wheels, rear spare, canopy and roof luggage. It remains the truck identified in source inspection, not a motorcycle. Compared with the source review, doors/body panels and windows show conspicuous angular warping, triangular gray folds and distorted edges; rear-quarter/side panels and canopy glazing are visibly degraded. Wheels remain recognizable, but fine rims/accessory detail is reduced. Body and wheels are still one static fused mesh with no rig/animation.

**Decision:** candidate for distant moving traffic only, conditional on actual gameplay-distance evaluation. Reject as a close hero vehicle/parked inspection prop without further work. No validated switching distance exists yet. A higher-detail LOD should take over before panel distortions become prominent. Do not report this as a seated/player motorcycle or a rigged vehicle.

## Overall conclusion and follow-up

All three files actually render and retain broad identity, but **render success is not visual acceptance**. FernLOD1 has a significant near-use rejection; jungle still needs diorama-aware integration; truck20k has conditional far-use only. Original material maps and source assets remain unchanged. No code/asset modification or commit was performed in this review.

Next steps: choose better near LODs, verify actual Unity material/normal/smoothness hookup, place the assets at intended distances, review camera movement/pop transitions and compare screenshots under the same conditions. Then profile memory/drawcalls/GPU on OppoFindX7Ultra/iPhone13. These Blender renders do not establish photoreal quality, Unity readiness or mobile performance.

## Fern quality retry v2 — supersedes rejection for the new files only

Root replaced the derivative outputs with a higher-fidelity retry; prior200k/about98k derivatives are preserved separately under `/workspace/library-files/meshy-optimization-history/FernTerraces/v1`. The earlier rejection above remains valid for those archived v1 files, **not the current v2 files**.

Designer reran the same explicit inspector with `--fbx-name FernTerraces_LOD0.fbx` and `FernTerraces_LOD1.fbx`, fresh outputs `/tmp/meshy-fern-quality-lod0` and `lod1`, and actually opened all four resulting images. Same supplied PBR maps and inspector camera setup were used. Actual measurements: LOD0: 599,998 imported triangles; LOD1: 299,998 imported triangles.

**Visual decision: PASS for the v2 asset silhouette/ground-continuity retry, for both LODs at the inspected full-patch views.** Fronds retain recognizable fine leaflets rather than broad pointed shards; rocks regain rounded shapes; rear soil/root surfaces are continuous rather than enormous folded fans. The severe artifacts that caused v1 rejection are no longer visible in these front/reverse views. LOD1 has slightly thinner small foliage detail and less distinct roots/soil microdetail, but does not show the prior major silhouette/base damage.

This is not an unrestricted close-up or gameplay acceptance: the source still has rectangular diorama boundaries/cut soil walls and needs intentional blending with terrain. Macro inspection closer than these views, moving LOD transitions, actual Unity materials/placement and mobile budgets are untested. The higher triangle counts may be expensive; visual PASS does not establish performance or automatically enable `apply_in_demo`. Keep that toggle a separate reviewed integration decision. No original maps or source mesh were edited by this review.

Saved v2 evidence: `docs/art/meshy-derived-fern-v2-lod{0,1}-{front-blender.png,reverse-blender.png,report.json}`. These remain Blender renders, not Unity screenshots.
