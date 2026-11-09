using UnityEngine;

namespace VietTrail.Rendering
{
    /// <summary>Canonical palette data, usable even when the PNG importer is unavailable.</summary>
    public static class PainterlyPalette
    {
        public const string GeneratedResource = "Theme/PainterlyPaletteGenerated";
        static readonly uint[] Pigments = {
            0x70685Du, 0xAB815Bu, 0x344F43u, 0x64805Au, 0x9CAF70u, 0x91A466u, 0xCDB773u, 0x918673u,
            0x8C9F90u, 0xEFE0B9u, 0xB96C55u, 0x424B49u, 0xD6AA83u, 0x77815Eu, 0xB89962u, 0x647E88u,
            0x7CABA3u, 0xAA7056u, 0x82664Fu, 0xE9DFC2u, 0xCCB68Bu, 0x554D3Fu, 0xA18B66u, 0x78875Au,
            0x5C7968u, 0xB1BF84u, 0xB69A6Bu, 0x87654Fu, 0x706D63u, 0xB3A58Bu, 0xEEE3C7u, 0xDFC5A1u,
            0xAAC6BFu, 0xBAC7ABu, 0xD6B565u, 0xC28460u, 0x62584Bu, 0x855B48u, 0xCB9370u, 0xA49D60u,
            0xE2CF90u, 0x658D7Au, 0x4C756Fu, 0xB1C9B3u, 0x7D9491u, 0xA39471u, 0x907247u, 0x67523Cu,
            0xD6C5A2u, 0xAC9B7Bu, 0xF4DDA3u, 0xE4C584u, 0x9DAF9Cu, 0xBDC9AFu, 0x7F998Au, 0xA8BA97u,
            0x9C655Eu, 0xC59B84u, 0x737E79u, 0x3C4540u, 0xF5E9CAu, 0x34463Eu, 0xC98C54u, 0xBCCB8Du
        };
        public static Texture2D LoadOrCreate(out bool owned)
        {
            var texture = Resources.Load<Texture2D>("Theme/PainterlyPalette");
            if (texture == null) texture = Resources.Load<Texture2D>(GeneratedResource);
            owned = texture == null;
            return texture != null ? texture : CreateTexture();
        }
        public static Texture2D CreateTexture()
        {
            var texture = new Texture2D(512,512,TextureFormat.RGBA32,false,false) {
                name="PainterlyPaletteGenerated", filterMode=FilterMode.Point, wrapMode=TextureWrapMode.Clamp
            };
            var pixels = new Color32[512*512];
            for(int y=0;y<512;y++) for(int x=0;x<512;x++)
            {
                // Texture2D rows start at bottom, matching palette UVs in all generated meshes.
                uint rgb=Pigments[(y/64)*8+x/64];
                pixels[y*512+x]=new Color32((byte)(rgb>>16),(byte)(rgb>>8),(byte)rgb,255);
            }
            texture.SetPixels32(pixels); texture.Apply(false,false);
            return texture;
        }
    }
}
