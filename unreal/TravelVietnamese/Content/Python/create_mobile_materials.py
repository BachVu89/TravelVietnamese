"""Run inside UE5 editor Python, not system Python.

Creates original parameter-only opaque PBR placeholders. No scans, puddle masks,
normal maps, weather simulation or photorealistic claim. Existing assets are kept.
Outputs must be saved, assigned to the map's actor slots, then cooked.
"""
import unreal

DESTINATION = '/Game/TravelVietnamese/Materials'
# Linear RGB, approximate artist values, not measured real-world materials.
SURFACES = {
    'M_RoadWet': ((0.12, 0.13, 0.14), 0.88, (0.035, 0.042, 0.048), 0.24, False),
    'M_RockWet': ((0.28, 0.25, 0.21), 0.95, (0.12, 0.11, 0.09), 0.50, False),
    'M_FoliageWet': ((0.07, 0.16, 0.045), 0.80, (0.025, 0.08, 0.025), 0.38, True),
    'M_BarkWet': ((0.16, 0.10, 0.055), 0.96, (0.065, 0.04, 0.025), 0.66, False),
}


def expression(material, kind, x, y, **properties):
    node = unreal.MaterialEditingLibrary.create_material_expression(material, kind, x, y)
    for name, value in properties.items():
        node.set_editor_property(name, value)
    return node


def create_material(name, dry_color, dry_roughness, wet_color, wet_roughness, two_sided):
    path = DESTINATION + '/' + name
    if unreal.EditorAssetLibrary.does_asset_exist(path):
        unreal.log('KEEP existing material: ' + path)
        return unreal.load_asset(path)
    material = unreal.AssetToolsHelpers.get_asset_tools().create_asset(
        name, DESTINATION, unreal.Material, unreal.MaterialFactoryNew())
    if material is None:
        raise RuntimeError('Could not create material: ' + path)
    material.set_editor_property('blend_mode', unreal.BlendMode.BLEND_OPAQUE)
    material.set_editor_property('two_sided', two_sided)
    library = unreal.MaterialEditingLibrary
    dry = expression(material, unreal.MaterialExpressionVectorParameter, -600, -200,
                     parameter_name='DryColor', default_value=unreal.LinearColor(*dry_color, 1.0))
    wet = expression(material, unreal.MaterialExpressionVectorParameter, -600, 0,
                     parameter_name='WetColor', default_value=unreal.LinearColor(*wet_color, 1.0))
    wetness = expression(material, unreal.MaterialExpressionScalarParameter, -600, 200,
                         parameter_name='Wetness', default_value=0.55, slider_min=0.0, slider_max=1.0)
    clamp = expression(material, unreal.MaterialExpressionClamp, -360, 200,
                       min_default=0.0, max_default=1.0)
    library.connect_material_expressions(wetness, '', clamp, 'Input')
    color_mix = expression(material, unreal.MaterialExpressionLinearInterpolate, -120, -100)
    library.connect_material_expressions(dry, '', color_mix, 'A')
    library.connect_material_expressions(wet, '', color_mix, 'B')
    library.connect_material_expressions(clamp, '', color_mix, 'Alpha')
    library.connect_material_property(color_mix, '', unreal.MaterialProperty.MP_BASE_COLOR)
    dry_r = expression(material, unreal.MaterialExpressionScalarParameter, -600, 400,
                       parameter_name='DryRoughness', default_value=dry_roughness)
    wet_r = expression(material, unreal.MaterialExpressionScalarParameter, -600, 550,
                       parameter_name='WetRoughness', default_value=wet_roughness)
    rough_mix = expression(material, unreal.MaterialExpressionLinearInterpolate, -120, 400)
    library.connect_material_expressions(dry_r, '', rough_mix, 'A')
    library.connect_material_expressions(wet_r, '', rough_mix, 'B')
    library.connect_material_expressions(clamp, '', rough_mix, 'Alpha')
    library.connect_material_property(rough_mix, '', unreal.MaterialProperty.MP_ROUGHNESS)
    metal = expression(material, unreal.MaterialExpressionConstant, -120, 600, r=0.0)
    library.connect_material_property(metal, '', unreal.MaterialProperty.MP_METALLIC)
    library.recompile_material(material)
    unreal.EditorAssetLibrary.set_metadata_tag(material, 'TravelSource', 'Original parameter-only placeholder')
    unreal.EditorAssetLibrary.save_loaded_asset(material)
    unreal.log('CREATED placeholder PBR material: ' + path)
    return material


def create_all():
    unreal.EditorAssetLibrary.make_directory(DESTINATION)
    return {name: create_material(name, *values) for name, values in SURFACES.items()}


if __name__ == '__main__':
    create_all()
