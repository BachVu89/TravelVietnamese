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

static func _ramp_texture(seed_value: int, frequency: float, colors: PackedColorArray) -> NoiseTexture2D:
	var texture := _noise_texture(seed_value, frequency)
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
	material.albedo_texture = _ramp_texture(4147, 0.11, PackedColorArray([
		Color("20292c"), Color("2c3538"), Color("394244")]))
	material.roughness = 0.86
	# A restrained damp sheen; roughness remains above ~0.48, never mirror-like.
	material.roughness_texture = _ramp_texture(9812, 0.025, PackedColorArray([
		Color(0.56, 0.56, 0.56), Color(0.8, 0.8, 0.8), Color.WHITE]))
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.metallic = 0.0
	material.metallic_specular = 0.28
	var bump := _noise_texture(4147, 0.21)
	bump.as_normal_map = true
	bump.bump_strength = 0.6
	material.normal_enabled = true
	material.normal_texture = bump
	material.normal_scale = 0.18
	# Geometry supplies metric UVs; a 256px tile repeats about once per two metres.
	material.uv1_scale = Vector3(0.5, 0.5, 0.5)
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
		Color("3f5146"), Color("5b675c"), Color("788076"), Color("92968b")]))
	material.roughness = 0.96
	material.metallic_specular = 0.18
	# World triplanar avoids dependence on imported cliff UVs. Different axis scales
	# stretch noise into thin strata; physical silhouette still belongs to geometry.
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.1, 0.65, 0.1)
	material.uv1_triplanar_sharpness = 4.0
	var bump := _noise_texture(5921, 0.065)
	bump.as_normal_map = true
	bump.bump_strength = 1.4
	material.normal_enabled = true
	material.normal_texture = bump
	material.normal_scale = 0.32
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
		Color("354e3c"), Color("526a46"), Color("697851")]))
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
	material.albedo_color = Color("9faeaa")
	material.metallic = 0.38
	material.metallic_specular = 0.3
	material.roughness = 0.68
	_cache["metal"] = material
	return material
