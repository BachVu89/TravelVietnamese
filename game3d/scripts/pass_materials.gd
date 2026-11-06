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
	material.resource_name = "Damp asphalt — CC0 scan texture (Poly Haven asphalt_01)"
	# Real scanned asphalt (CC0), tinted darker toward the wet look of the
	# reference photo; its own roughness map keeps the restrained damp sheen.
	material.albedo_color = Color(0.60, 0.62, 0.63)
	material.albedo_texture = load("res://assets/textures/asphalt_01/asphalt_01_Diffuse_1k.jpg") as Texture2D
	material.roughness = 1.0
	material.roughness_texture = load("res://assets/textures/asphalt_01/asphalt_01_Rough_1k.jpg") as Texture2D
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.metallic = 0.0
	material.metallic_specular = 0.28
	material.normal_enabled = true
	material.normal_texture = load("res://assets/textures/asphalt_01/asphalt_01_nor_gl_1k.jpg") as Texture2D
	material.normal_scale = 0.4
	# Current pass strip supplies world XZ * 0.16 UVs: scale 2 gives a
	# ~3.125 m tile. Geometry unchanged.
	material.uv1_scale = Vector3(2.0, 2.0, 2.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_cache["road"] = material
	return material

static func rock() -> StandardMaterial3D:
	if _cache.has("rock"):
		return _cache["rock"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Mossy cliff rock — CC0 scan texture (Poly Haven dark_rock)"
	material.albedo_color = Color.WHITE
	material.albedo_texture = load("res://assets/textures/dark_rock/dark_rock_Diffuse_1k.jpg") as Texture2D
	material.roughness = 0.96
	material.metallic_specular = 0.18
	# World triplanar avoids dependence on imported cliff UVs; physical
	# silhouette still belongs to geometry.
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.16, 0.24, 0.16)
	material.uv1_triplanar_sharpness = 4.0
	material.normal_enabled = true
	material.normal_texture = load("res://assets/textures/dark_rock/dark_rock_nor_gl_1k.jpg") as Texture2D
	material.normal_scale = 0.5
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_cache["rock"] = material
	return material

static func grass() -> StandardMaterial3D:
	if _cache.has("grass"):
		return _cache["grass"]
	var material := StandardMaterial3D.new()
	material.resource_name = "Forest ground — CC0 scan texture (Poly Haven aerial_grass_rock)"
	# The scan is dry olive; a green multiply pulls the slopes toward the
	# lush pass in the reference photo.
	material.albedo_color = Color(0.66, 0.92, 0.55)
	material.albedo_texture = load("res://assets/textures/aerial_grass_rock/aerial_grass_rock_Diffuse_1k.jpg") as Texture2D
	material.normal_enabled = true
	material.normal_texture = load("res://assets/textures/aerial_grass_rock/aerial_grass_rock_nor_gl_1k.jpg") as Texture2D
	material.normal_scale = 0.7
	material.roughness = 1.0
	material.roughness_texture = load("res://assets/textures/aerial_grass_rock/aerial_grass_rock_Rough_1k.jpg") as Texture2D
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.metallic_specular = 0.12
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.22, 0.22, 0.22)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
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
