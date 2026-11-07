"""Run only AFTER the UE5.5 C++ editor target compiles.
Creates an original local preview level. Does not fetch assets or package a game.
Editor: Tools > Execute Python Script, select this file.
"""
import unreal

if unreal.EditorLoadingAndSavingUtils.get_dirty_map_packages():
    raise RuntimeError("Save or close modified maps before generating a new preview level.")

MAP_PATH = "/Game/Maps/PassPreview"
assets = unreal.get_editor_subsystem(unreal.EditorAssetSubsystem)
levels = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
actors = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
if assets.does_asset_exist(MAP_PATH):
    raise RuntimeError("Preview map already exists; refusing to overwrite user work: " + MAP_PATH)
cls = unreal.load_class(None, "/Script/TravelVietnamese.TravelPassEnvironment")
if cls is None:
    raise RuntimeError("Compile TravelVietnameseEditor for UE5.5 before running bootstrap.")
if not levels.new_level(MAP_PATH):
    raise RuntimeError("Cannot create preview map")
environment = actors.spawn_actor_from_class(cls, unreal.Vector(0, 0, 0))
# Original, parameter-only materials; the generator preserves any existing assets.
import create_mobile_materials
materials = create_mobile_materials.create_all()
for slot, asset_name in {"road_material": "M_RoadWet", "rock_material": "M_RockWet",
                         "foliage_material": "M_FoliageWet", "trunk_material": "M_BarkWet"}.items():
    if environment.get_editor_property(slot) is None:
        environment.set_editor_property(slot, materials[asset_name])
environment.regenerate()
sun = actors.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0, 0, 10000), unreal.Rotator(-45, -30, 0))
sun.set_actor_label("Preview Sun")
actors.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0, 0, 0))
actors.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0, 0, 1000))
fog = actors.spawn_actor_from_class(unreal.ExponentialHeightFog, unreal.Vector(0, 0, 0))
fog.set_actor_label("Preview Height Fog - tune on device")
actors.spawn_actor_from_class(unreal.PlayerStart, unreal.Vector(-1000, 0, 1200))
if not levels.save_current_level():
    raise RuntimeError("Preview map created but save failed")
unreal.log("Created " + MAP_PATH + ". Placeholder meshes/material slots only; visual, collision and mobile cook remain unverified.")
