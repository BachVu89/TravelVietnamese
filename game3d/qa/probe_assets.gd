extends SceneTree

# One-off probe: report each imported model's AABB and surface materials so
# vegetation.gd can use correct native heights and alpha modes.

const NAMES := ["Pine_1", "Pine_2", "Tree_1", "Tree_2", "Tree_3", "Twisted_Tree_1", "Bush_1", "Bush_with_Flowers_1", "Fern_1", "Grass_Wispy_1", "Tall_Grass_1", "Rock_Medium_1", "Rock_Medium_2", "Plant_1", "Plant_Big_1"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for name in NAMES:
		var scene: PackedScene = load("res://assets/models/quaternius/" + name + ".glb")
		if scene == null:
			print("PROBE ", name, " LOAD_FAIL")
			continue
		var node := scene.instantiate()
		root.add_child(node)
		var meshes: Array[MeshInstance3D] = []
		_collect(node, meshes)
		var aabb := AABB()
		var first := true
		var mats: Array[String] = []
		for mi in meshes:
			var local := mi.get_aabb()
			var xf := mi.global_transform
			var corners := []
			for i in range(8):
				corners.append(xf * local.get_endpoint(i))
			for c in corners:
				if first:
					aabb = AABB(c, Vector3.ZERO)
					first = false
				else:
					aabb = aabb.expand(c)
			for s in range(mi.mesh.get_surface_count()):
				var m := mi.mesh.surface_get_material(s)
				if m is BaseMaterial3D:
					mats.append(str(m.resource_name) + "|alpha=" + str(m.transparency) + "|scissor=" + str(m.alpha_scissor_threshold) + "|shaded=" + str(m.shading_mode))
				else:
					mats.append(str(m))
		print("PROBE ", name, " size=", aabb.size, " pos_y=", aabb.position.y, " surfaces=", mats)
		node.queue_free()
	quit(0)

func _collect(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node)
	for child in node.get_children():
		_collect(child, out)
