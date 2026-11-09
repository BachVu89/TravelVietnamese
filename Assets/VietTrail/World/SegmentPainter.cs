using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace VietTrail.World
{
    /// <summary>Original palette-only scenery. No external assets, textures or runtime downloads.</summary>
    public static class SegmentPainter
    {
        public static Vector2 PaletteUV(int id) { return PaletteUV(id % 8, id / 8); }
        public static Vector2 PaletteUV(int col, int row) { return new Vector2((col + .5f) / 8f, (row + .5f) / 8f); }

        public static void Build(GameObject parent, float start, float end, Material palette)
        {
            var road = new Geometry();
            var scenery = new Geometry();
            const float step = 4f;
            for (float s = start; s < end - .001f; s += step)
            {
                float next = Mathf.Min(s + step, end);
                float edge0 = TrailPath.RightEdge(s), edge1 = TrailPath.RightEdge(next);
                road.Quad(TrailPath.RoadPoint(s, -2.8f), TrailPath.RoadPoint(s, edge0),
                    TrailPath.RoadPoint(next, -2.8f), TrailPath.RoadPoint(next, edge1), 0);
                // Thin continuous margin marks, geometry above the road, not separate objects.
                foreach (float lane in new[] { -2.5f, 2.5f })
                    scenery.Quad(TrailPath.RoadPoint(s, lane - .035f) + Vector3.up * .018f,
                        TrailPath.RoadPoint(s, lane + .035f) + Vector3.up * .018f,
                        TrailPath.RoadPoint(next, lane - .035f) + Vector3.up * .018f,
                        TrailPath.RoadPoint(next, lane + .035f) + Vector3.up * .018f, 19);
                if ((Mathf.FloorToInt(s / 4f) & 1) == 0)
                    scenery.Quad(TrailPath.RoadPoint(s, -.045f) + Vector3.up * .02f,
                        TrailPath.RoadPoint(s, .045f) + Vector3.up * .02f,
                        TrailPath.RoadPoint(Mathf.Min(s + 2f, next), -.045f) + Vector3.up * .02f,
                        TrailPath.RoadPoint(Mathf.Min(s + 2f, next), .045f) + Vector3.up * .02f, 6);
                Ground(sceneries: scenery, s: s, next: next, rightSide: false);
                Ground(sceneries: scenery, s: s, next: next, rightSide: true);
                if ((Mathf.FloorToInt(s / 4f) & 1) == 0)
                {
                    Rail(scenery, s, next, -3.05f, -3.05f);
                    // No rail across the bay entrance: widened edge follows the bay itself.
                    Rail(scenery, s, next, edge0 + .2f, edge1 + .2f);
                }
            }
            for (int k = Mathf.CeilToInt(start / 7f); k * 7f < end; k++)
            {
                float s = k * 7f;
                for (int side = -1; side <= 1; side += 2)
                {
                    float noise = Hash(k * 11 + side * 3);
                    float offset = side < 0 ? -(8f + noise * 35f) : TrailPath.RightEdge(s) + 38f + noise * 22f;
                    Vector3 basePoint = GroundPoint(s, offset);
                    Tree(scenery, basePoint, 4f + Hash(k * 31 + side) * 5f, k + side);
                }
            }
            road.Create(parent.transform, "Road and bay collision", palette, true);
            scenery.Create(parent.transform, "Palette landscape", palette, false);
        }

        static float Hash(int seed)
        {
            unchecked { uint n = (uint)seed * 747796405u + 2891336453u; n = ((n >> 13) ^ n) * 277803737u; return (n & 65535u) / 65535f; }
        }

        public static Vector3 RoadsideGrassPoint(float s, float lane)
        {
            // Match the actual first terrain strip, not an independent height approximation.
            float a = Mathf.Floor(s / 4f) * 4f, b = Mathf.Min(a + 4f, TrailPath.Length);
            float t = Mathf.InverseLerp(a, b, s);
            Vector3 pa, pb;
            if (lane < 0)
            {
                float u = Mathf.InverseLerp(-2.8f, -8f, lane);
                pa = Vector3.Lerp(GroundPoint(a,-2.8f),GroundPoint(a,-8f),u);
                pb = Vector3.Lerp(GroundPoint(b,-2.8f),GroundPoint(b,-8f),u);
            }
            else
            {
                float outward = lane - TrailPath.RightEdge(s);
                float widthA = 8 + Mathf.Sin(a*.015f)*.28f;
                float widthB = 8 + Mathf.Sin(b*.015f)*.28f;
                pa = TrailPath.RoadPoint(a,TrailPath.RightEdge(a)+outward); pa.y -= outward/widthA*.2f;
                pb = TrailPath.RoadPoint(b,TrailPath.RightEdge(b)+outward); pb.y -= outward/widthB*.2f;
            }
            return Vector3.Lerp(pa,pb,t) - Vector3.up*.025f;
        }

        static Vector3 GroundPoint(float s, float lane)
        {
            Vector3 point = TrailPath.RoadPoint(s, lane);
            float outward = lane < 0 ? Mathf.Max(0f, -lane - 2.8f) : Mathf.Max(0f, lane - TrailPath.RightEdge(s));
            if (lane < 0)
                point.y += (1f - Mathf.Exp(-outward / 36f)) * 31f + Mathf.Sin(s * .012f + outward * .035f) * Mathf.Min(outward * .055f, 2.5f);
            else
                point.y -= Mathf.Floor(outward / 8f) * .9f + outward * .025f;
            return point;
        }

        static void Ground(Geometry sceneries, float s, float next, bool rightSide)
        {
            if (!rightSide)
            {
                float[] lanes = { -2.8f, -8f, -17f, -31f, -52f, -82f, -120f };
                for (int i = 0; i < lanes.Length - 1; i++)
                    sceneries.Quad(GroundPoint(s, lanes[i + 1]), GroundPoint(s, lanes[i]),
                        GroundPoint(next, lanes[i + 1]), GroundPoint(next, lanes[i]), i < 2 ? 7 : 2, true);
                return;
            }
            // Contoured field treads and short risers; never one stretched cliff triangle.
            for (int terrace = 0; terrace < 11; terrace++)
            {
                float inner = terrace * 8f, outer = inner + 8f;
                float bend0 = Mathf.Sin(s * .015f) * Mathf.Min(inner * .035f, 2.0f);
                float bend1 = Mathf.Sin(next * .015f) * Mathf.Min(inner * .035f, 2.0f);
                float outerBend0 = Mathf.Sin(s * .015f) * Mathf.Min(outer * .035f, 2.0f);
                float outerBend1 = Mathf.Sin(next * .015f) * Mathf.Min(outer * .035f, 2.0f);
                float edge0 = TrailPath.RightEdge(s), edge1 = TrailPath.RightEdge(next);
                Vector3 a = TrailPath.RoadPoint(s, edge0 + inner + bend0);
                Vector3 b = TrailPath.RoadPoint(s, edge0 + outer + outerBend0);
                Vector3 c = TrailPath.RoadPoint(next, edge1 + inner + bend1);
                Vector3 d = TrailPath.RoadPoint(next, edge1 + outer + outerBend1);
                float drop = terrace * .9f + inner * .025f;
                a.y -= drop; c.y -= drop;
                b.y -= drop + .2f; d.y -= drop + .2f;
                sceneries.Quad(a, b, c, d, terrace % 3 == 1 ? 6 : 5, true);
                Vector3 lowerB = b - Vector3.up * .9f, lowerD = d - Vector3.up * .9f;
                sceneries.Quad(b, lowerB, d, lowerD, 1, true);
            }
        }

        static void Rail(Geometry mesh, float s, float next, float lane0, float lane1)
        {
            Vector3 a = TrailPath.RoadPoint(s, lane0), b = TrailPath.RoadPoint(next, lane1);
            mesh.Beam(a + Vector3.up * .72f, b + Vector3.up * .72f, .065f, 9);
            mesh.Beam(a, a + Vector3.up * .9f, .055f, 18);
        }

        static void Tree(Geometry mesh, Vector3 point, float height, int seed)
        {
            mesh.Beam(point, point + Vector3.up * (height * .66f), .19f, 18);
            int color = seed % 3 == 0 ? 4 : seed % 2 == 0 ? 3 : 2;
            mesh.Crown(point + Vector3.up * (height * .38f), height * .32f, height * .55f, color);
            mesh.Crown(point + Vector3.up * (height * .62f), height * .23f, height * .43f, color);
        }

        sealed class Geometry
        {
            readonly List<Vector3> vertices = new List<Vector3>();
            readonly List<int> indices = new List<int>();
            readonly List<Vector2> uvs = new List<Vector2>();
            readonly List<Color32> colors = new List<Color32>();
            int Add(Vector3 point, int color, bool terrain)
            {
                int index = vertices.Count; vertices.Add(point); uvs.Add(PaletteUV(color));
                colors.Add(new Color32(255, 255, 255, terrain ? (byte)255 : (byte)0)); return index;
            }
            public void Quad(Vector3 a, Vector3 b, Vector3 c, Vector3 d, int color, bool terrain = false)
            {
                int k = vertices.Count; Add(a, color, terrain); Add(b, color, terrain); Add(c, color, terrain); Add(d, color, terrain);
                indices.Add(k); indices.Add(k + 2); indices.Add(k + 1);
                indices.Add(k + 1); indices.Add(k + 2); indices.Add(k + 3);
            }
            void Triangle(Vector3 a, Vector3 b, Vector3 c, int color)
            { int k = vertices.Count; Add(a, color, false); Add(b, color, false); Add(c, color, false); indices.Add(k); indices.Add(k + 1); indices.Add(k + 2); }
            public void Beam(Vector3 a, Vector3 b, float width, int color)
            {
                Vector3 direction = (b - a).normalized;
                Vector3 x = Vector3.Cross(direction, Mathf.Abs(direction.y) > .9f ? Vector3.forward : Vector3.up).normalized * width;
                Vector3 y = Vector3.Cross(direction, x).normalized * width;
                Vector3[] ring = { x + y, -x + y, -x - y, x - y };
                for (int i = 0; i < 4; i++) { int j = (i + 1) % 4; Quad(a + ring[j], a + ring[i], b + ring[j], b + ring[i], color); }
            }
            public void Crown(Vector3 center, float radius, float height, int color)
            {
                const int sides = 6;
                for (int i = 0; i < sides; i++)
                {
                    float angle = i * Mathf.PI * 2f / sides, next = (i + 1) * Mathf.PI * 2f / sides;
                    Vector3 a = center + new Vector3(Mathf.Cos(angle) * radius, 0, Mathf.Sin(angle) * radius);
                    Vector3 b = center + new Vector3(Mathf.Cos(next) * radius, 0, Mathf.Sin(next) * radius);
                    Triangle(b, a, center + Vector3.up * height, color);
                }
            }
            public void Create(Transform parent, string name, Material palette, bool collision)
            {
                var child = new GameObject(name); child.transform.SetParent(parent, false);
                var mesh = new Mesh { name = name, indexFormat = vertices.Count > 65535 ? IndexFormat.UInt32 : IndexFormat.UInt16 };
                mesh.SetVertices(vertices); mesh.SetTriangles(indices, 0); mesh.SetUVs(0, uvs); mesh.SetColors(colors);
                mesh.RecalculateNormals(); mesh.RecalculateBounds();
                var tangents = new Vector4[vertices.Count];
                Vector3[] normals = mesh.normals;
                for (int i = 0; i < tangents.Length; i++)
                {
                    Vector3 tangent = Vector3.ProjectOnPlane(Vector3.right, normals[i]);
                    if (tangent.sqrMagnitude < .001f) tangent = Vector3.ProjectOnPlane(Vector3.forward, normals[i]);
                    tangent.Normalize();
                    tangents[i] = new Vector4(tangent.x, tangent.y, tangent.z, 1f);
                }
                mesh.tangents = tangents;
                child.AddComponent<MeshFilter>().sharedMesh = mesh;
                child.AddComponent<MeshRenderer>().sharedMaterial = palette;
                if (collision) child.AddComponent<MeshCollider>().sharedMesh = mesh;
            }
        }
    }
}
