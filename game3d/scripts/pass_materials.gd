## Original procedural surface materials for the illustrative mountain pass.
## Shared resources: do not mutate returned materials per mesh; duplicate if needed.
## Uses StandardMaterial3D only: no SSR, custom shaders or external textures.
class_name TravelPassMaterials
extends RefCounted

static var _cache: Dictionary = {}

static func _noise_texture(seed_value: int, frequency: float, size: int = 256) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = frequency
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.5
	var texture := NoiseTexture2D.new()
	texture.width = size
	texture.height = size
	texture.noise = noise
	texture.seamless = true
	texture.generate_mipmaps = true
	texture.normalize = true
	return texture

static func _ramp_texture(seed_value: int, frequency: float, colors: PackedColorArray, size: int = 256) -> NoiseTexture2D:
	var texture := _noise_texture(seed_value, frequency, size)
	var ramp := Gradient.new()
	var offsets := PackedFloat32Array()
	for index in colors.size():
		offsets.append(float(index) / maxf(float(colors.size() - 1), 1.0))
	ramp.offsets = offsets
	ramp.colors = colors
	texture.color_ramp = ramp
	return texture

static func road() -> StandardMaterial3D:
	if _cache.has("road"):
		return _cache["road"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original damp asphalt — no real-world scan"
	material.albedo_color = Color.WHITE
	material.albedo_texture = _ramp_texture(4147, 0.38, PackedColorArray([
		Color("222a2c"), Color("2b3335"), Color("353d3e")]), 512)
	material.roughness = 0.86
	# A restrained damp sheen; roughness remains above ~0.48, never mirror-like.
	material.roughness_texture = _ramp_texture(9812, 0.012, PackedColorArray([
		Color(0.56, 0.56, 0.56), Color(0.8, 0.8, 0.8), Color.WHITE]))
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.metallic = 0.0
	material.metallic_specular = 0.28
	var bump := _noise_texture(4147, 0.38, 512)
	bump.as_normal_map = true
	bump.bump_strength = 0.35
	material.normal_enabled = true
	material.normal_texture = bump
	material.normal_scale = 0.12
	# Current pass strip supplies world XZ * 0.16 UVs: scale 2 gives a
	# ~3.125 m tile instead of the former blurry 12.5 m tile. Geometry unchanged.
	material.uv1_scale = Vector3(2.0, 2.0, 2.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_cache["road"] = material
	return material

static func rock() -> StandardMaterial3D:
	if _cache.has("rock"):
		return _cache["rock"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original mossy strata rock"
	material.albedo_color = Color.WHITE
	material.albedo_texture = _ramp_texture(5921, 0.035, PackedColorArray([
		Color("3e4b3e"), Color("5e6353"), Color("7b7b68"), Color("93917d")]))
	material.roughness = 0.96
	material.metallic_specular = 0.18
	# World triplanar avoids dependence on imported cliff UVs. Different axis scales
	# stretch noise into thin strata; physical silhouette still belongs to geometry.
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.14, 0.28, 0.14)
	material.uv1_triplanar_sharpness = 4.0
	var bump := _noise_texture(5921, 0.065)
	bump.as_normal_map = true
	bump.bump_strength = 1.4
	material.normal_enabled = true
	material.normal_texture = bump
	material.normal_scale = 0.24
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_cache["rock"] = material
	return material

static func grass() -> StandardMaterial3D:
	if _cache.has("grass"):
		return _cache["grass"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original forest ground"
	material.albedo_color = Color.WHITE
	material.albedo_texture = _ramp_texture(7138, 0.055, PackedColorArray([
		Color("2e4231"), Color("435a38"), Color("637047")]))
	material.roughness = 1.0
	material.metallic_specular = 0.12
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.17, 0.17, 0.17)
	_cache["grass"] = material
	return material

static func metal() -> StandardMaterial3D:
	if _cache.has("metal"):
		return _cache["metal"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original satin galvanized rail"
	material.albedo_color = Color("87948e")
	material.metallic = 0.22
	material.metallic_specular = 0.3
	material.roughness = 0.78
	_cache["metal"] = material
	return material


static func foliage() -> StandardMaterial3D:
	if _cache.has("foliage"):
		return _cache["foliage"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original opaque geometry foliage — instance tinted"
	material.albedo_color = Color.WHITE
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	material.metallic_specular = 0.08
	# Solid geometry foliage: no alpha overdraw/card shadows or external assets.
	_cache["foliage"] = material
	return material

static func bark() -> StandardMaterial3D:
	if _cache.has("bark"):
		return _cache["bark"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Original damp bark"
	material.albedo_color = Color.WHITE
	material.albedo_texture = _ramp_texture(18051, 0.07, PackedColorArray([
		Color("302f24"), Color("474636"), Color("62604a")]))
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.65, 0.12, 0.65)
	material.roughness = 1.0
	material.metallic_specular = 0.08
	_cache["bark"] = material
	return material
