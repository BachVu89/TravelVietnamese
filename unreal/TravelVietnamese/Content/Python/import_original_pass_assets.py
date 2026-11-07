"""UE5 editor-only import of original local FBX exports; preserves existing assets.

No network, marketplace, plugin purchase or runtime import. Run after editor build;
bootstrap_pass.py calls import_all(). UE import APIs/cook require engine validation.
"""
from pathlib import Path
import unreal

DESTINATION = '/Game/TravelVietnamese/Original'
ASSETS = {
    'rock_outcrop_mesh': 'SM_CliffRock',
    'fern_mesh': 'SM_Fern',
    'banana_mesh': 'SM_BananaClump',
}


def import_all():
    source = Path(unreal.Paths.convert_relative_path_to_full(unreal.Paths.project_dir())) / 'ArtSource'
    # Resolve all files before mutating the content browser.
    for name in ASSETS.values():
        if not (source / (name + '.fbx')).is_file():
            raise RuntimeError('Missing original FBX; run scripts/art/create-pass-assets.py: ' + str(source / name))
    unreal.EditorAssetLibrary.make_directory(DESTINATION)
    results = {}
    for slot, name in ASSETS.items():
        object_path = DESTINATION + '/' + name
        if unreal.EditorAssetLibrary.does_asset_exist(object_path):
            mesh = unreal.load_asset(object_path)
            if not isinstance(mesh, unreal.StaticMesh):
                raise RuntimeError('Refusing to replace a non-mesh asset: ' + object_path)
            results[slot] = mesh
            continue
        existing_assets = set(unreal.EditorAssetLibrary.list_assets(DESTINATION, recursive=True))
        options = unreal.FbxImportUI()
        options.set_editor_property('automated_import_should_detect_type', False)
        options.set_editor_property('mesh_type_to_import', unreal.FBXImportType.FBXIT_STATIC_MESH)
        options.set_editor_property('import_mesh', True)
        options.set_editor_property('import_materials', True)
        options.set_editor_property('import_textures', False)
        data = options.get_editor_property('static_mesh_import_data')
        data.set_editor_property('combine_meshes', True)
        data.set_editor_property('auto_generate_collision', False)
        data.set_editor_property('generate_lightmap_u_vs', True)
        data.set_editor_property('convert_scene', True)
        data.set_editor_property('convert_scene_unit', True)
        task = unreal.AssetImportTask()
        for key, value in {
            'filename': str(source / (name + '.fbx')),
            'destination_path': DESTINATION, 'destination_name': name,
            'automated': True, 'save': True, 'replace_existing': False, 'options': options,
        }.items():
            task.set_editor_property(key, value)
        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
        mesh = unreal.load_asset(object_path)
        if not isinstance(mesh, unreal.StaticMesh):
            raise RuntimeError('FBX import did not create expected StaticMesh: ' + object_path)
        # Thin original leaf surfaces need both sides. Only adjust newly imported
        # materials; preserve existing artist-authored materials and their colors.
        leaf_names = {'M_Fern_Leaf', 'M_Banana_Leaf', 'M_Banana_LeafTip'}
        for section in mesh.get_editor_property('static_materials'):
            material = section.get_editor_property('material_interface')
            if isinstance(material, unreal.Material) and material.get_name() in leaf_names:
                if material.get_path_name() not in existing_assets:
                    material.set_editor_property('two_sided', True)
                    unreal.MaterialEditingLibrary.recompile_material(material)
                    unreal.EditorAssetLibrary.save_loaded_asset(material)
        results[slot] = mesh
    return results


def assign_empty_slots(environment):
    meshes = import_all()
    for slot, mesh in meshes.items():
        if environment.get_editor_property(slot) is None:
            environment.set_editor_property(slot, mesh)
    environment.regenerate()
    return meshes


if __name__ == '__main__':
    import_all()
