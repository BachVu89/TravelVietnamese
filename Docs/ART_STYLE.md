# VietTrail — stylized painterly rendering contract

Fresh style direction: warm northern mountain pass, painted colour masses, clear silhouettes, layered forest/rice fields, soft atmospheric depth. This replaces the prior scan/PBR direction for the fresh project. Do not import previous normal/metallic/roughness texture stacks. No game screenshot, Unity shader compile or device performance is claimed by these source files; Unity is unavailable in this environment.

## Palette and shared materials

Original atlas: `Assets/VietTrail/Resources/Theme/PainterlyPalette.png`,512×512,8×8 cells of64px. Runtime `Resources.Load<Texture2D>("Theme/PainterlyPalette")`. One shared world material uses `Shader.Find("VietTrail/Painterly Lit")`; sky uses separate `Shader.Find("VietTrail/Painterly Sky")`. UI or future water can use separate materials; do not create a new world material for every colour/object.

UV for integer cellID0..63:

```csharp
new Vector2((id % 8 + .5f) / 8f, (id / 8 + .5f) / 8f)
```

PNG image rows are flipped in `Tools/MakePalette.py`: IDs0..7 appear at the image bottom, matching Unity UVv0. Assign the same cell-centre UV to every vertex of each coloured face; split vertices at palette boundaries. Never interpolate between two cell IDs across a face. Import sRGB, Point filtering, Clamp, mipmaps disabled, no lossy compression, max size512; record these importer settings in Editor creation code. Sampling exact centres avoids cell bleed. Reproduce with `python Tools/MakePalette.py`; it needs Pillow and has no image inputs.

| ID | Purpose | Hex |
| --- | --- | --- |
| 0 | Road gray-brown | #70685D |
| 1 | Clay shoulder | #AB815B |
| 2 | Deep forest | #344F43 |
| 3 | Leaf mid | #64805A |
| 4 | Leaf sun | #9CAF70 |
| 5 | Field green | #91A466 |
| 6 | Rice gold | #CDB773 |
| 7 | Warm rock | #918673 |
| 8 | Far gray-green | #8C9F90 |
| 9 | Cream | #EFE0B9 |
| 10 | Warm red | #B96C55 |
| 11 | Dark metal | #424B49 |
| 12 | Skin | #D6AA83 |
| 13 | Olive cloth | #77815E |
| 14 | Ochre backpack | #B89962 |
| 15 | Blue fabric | #647E88 |
| 16 | Water cyan | #7CABA3 |
| 17 | Roof terracotta | #AA7056 |
| 18 | Wood | #82664F |
| 19 | White road marking | #E9DFC2 |

IDs20..63 supply supporting earth, canopy, cloud, cloth and distant-layer colours; full original names/hex are in the generator. `Rendering/PainterlySwatches.png` presents the first16 colours with an explicit **not a game render** label. This is a colour artifact, not a concept-image substitute for scene validation.

## Mesh colour/lighting contract

Vertex RGB should be white by default, optionally multiply by a restrained art variation (e.g.0.9–1.05, never encode IDs there). Vertex **alpha is a terrain-height-tint mask, not transparency**: terrain uses alpha1; actors/vehicles/buildings alpha0 so their palette colour is not altered by world elevation. Set mesh colours explicitly—missing/default-black colours can make the model black. All meshes are opaque; no PBR normal/metallic/roughness maps are sampled. Author actual mesh normals and silhouette; flat/smoothed normals control the painted lighting.

World shader uses URP MainLight, soft two-step Lambert bands, main-light shadow attenuation and sampled SH ambient. No specular/reflection/GI fidelity claim. Main-light shadow renderer settings and SH ambient must be configured in scene. Original own ShadowCaster and DepthOnly passes support instancing, without reusing a Lit/PBR UsePass. URP variants cover main shadows/cascades/screen shadows and soft shadows; actual compatibility needs Unity compile/render gate.

## Exact world uniforms

| Name | Default / meaning |
| --- | --- |
| `_Palette` | Required original atlas texture; no other texture slots |
| `_ShadowTint` | (0.67,0.73,0.66,1), coloured shadow lighting |
| `_HeightLowTint` | (0.85,0.91,0.82,1), terrain valley tint |
| `_HeightHighTint` | (1.06,1.01,0.90,1), terrain high tint |
| `_HeightMin`, `_HeightMax` | 0,100 worldY; adapt once to scene elevation range |
| `_BandSoftness` |0.16; soft transitions around Lambert0.26 and0.7 |
| `_AmbientStrength` |0.75; multiplier for SH ambient |
| `_HazeColor` |(0.73,0.78,0.68,1), shared scene haze colour |
| `_FogDensity` |0.0018 exponential distance density, nonnegative |
| `_FogStart` |65 world units clear near radius |
| `_FogBaseHeight` |10 worldY; maximum valley-density altitude |
| `_FogHeightFalloff` |0.012; density fades upward |
| `_FogMax` |0.82 maximum haze blend; keeps near route readable |

Analytic fog is evaluated from world position and camera distance, with height attenuation. It is visual atmospheric haze, **not volumetric fog**, streaming, occlusion or evidence that unloaded world chunks exist. Chunk visibility/loading remains SA/runtime's responsibility. Keep fog and far-layer colours compatible; do not hide holes or missing terrain with excessive fog. URP built-in fog need not be added on top, avoiding double fog.

## Sky uniforms and cost

`Painterly Sky` uses vertical warm horizon/blue-green zenith gradient, broad static analytic cloud strokes and a soft sun/halo. No texture, noise volume, particles or volumetric dependency. `_ZenithColor`(.59,.74,.74), `_HorizonColor`(.88,.79,.63), `_GroundColor`(.65,.72,.61), `_SunColor`(1,.88,.65), `_SunDirection`(.3,.45,.7,0), `_SunSize`.008, `_CloudColor`(.94,.89,.75), `_CloudAmount`.35. Direction points **towards** sun; Editor should align it with the main light's direction-to-light, not its forward ray direction. This is a skybox material, not a world mesh material.

## Art review and readiness gates

Use irregular multi-cluster tree canopies, layered banks/rock silhouettes and clear warm roads/fields; a palette swap on box characters or flat cliffs does not satisfy the style. Review actual Unity captures at start/corner/vista and a moving third-person segment. Near route and rider must remain legible, terrain elevations must not recolour the rider, shadows must not turn foliage black, and horizon must meet haze without an obvious dark seam.

Gate status: palette PNG generated and pixel/UV mapping testable; shader source authored, **not compiled/rendered in Unity**. Check shader compiler logs, instanced draw shadows/depth, mobile render APIs, XR macros if used, cascade/screen-space shadow modes and depth pass behavior. Then profile on OppoFindX7Ultra/iPhone13. No FPS or native volumetric-fog claim is made. These original shaders/colours contain no marketplace/scan/reference-image content.
