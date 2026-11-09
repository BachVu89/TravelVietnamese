using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace VietTrail.Presentation
{
    /// <summary>Interactive illustrative journey diorama, not DEM/GIS or a geographical navigation map.
    /// Input is explicitly forwarded by UI owner, so dragging UI never moves the map accidentally.</summary>
    public sealed class JourneyMapView : MonoBehaviour
    {
        [Serializable] sealed class Chapter { public string id, name, status; public float mapX, mapZ; }
        [Serializable] sealed class Registry { public Chapter[] tourismChapters; }
        sealed class Pin { public Chapter chapter; public Transform root; public Collider hit; }
        readonly List<Pin> pins = new List<Pin>();
        readonly List<Mesh> ownedMeshes = new List<Mesh>();
        readonly List<Transform> clouds = new List<Transform>();
        readonly List<Vector3> cloudOrigins = new List<Vector3>();
        Material material;
        Transform contents, miniature;
        Vector3 focus = new Vector3(8000, 3, 0), targetFocus = new Vector3(8000, 3, 0);
        float yaw = -12, pitch = 53, radius = 140, progress;
        bool initialized, shown;
        public event Action<string> ChapterSelected;
        public bool IsShown { get { return shown; } }
        public string FocusedChapterId { get; private set; }

        public void Initialize(Material sharedPalette)
        {
            if (initialized) return;
            if (sharedPalette == null) throw new ArgumentNullException(nameof(sharedPalette));
            initialized = true; material = sharedPalette;
            var root = new GameObject("Illustrative S journey — not geographic data");
            contents = root.transform; contents.SetParent(transform, false); contents.position = new Vector3(8000, 0, 0);
            BuildTerrain(); BuildCanopies(); BuildChapters(); BuildRoute(); BuildClouds();
            var bike = new Shape();
            bike.Box(new Vector3(0, .4f, 0), new Vector3(1.1f, .65f, 2), 10);
            bike.Box(new Vector3(0, .85f, .2f), new Vector3(.8f, .25f, 1.2f), 11);
            bike.Box(new Vector3(0, 1.45f, .2f), new Vector3(.65f, 1, .5f), 13);
            bike.Pyramid(new Vector3(0, 2.1f, .2f), .5f, .4f, 9);
            miniature = Create("Animated route marker vehicle — illustrative", bike).transform;
            Show(false);
        }

        static float Spine(float t) { return Mathf.Sin((t - .15f) * Mathf.PI * 2) * 13; }
        static float Width(float t) { return 8 + Mathf.Pow(t, 1.5f) * 5 + Mathf.Sin(t * Mathf.PI) * 2; }
        static float Ground(float t, float side)
        {
            float north = Mathf.SmoothStep(0, 1, Mathf.InverseLerp(.45f, .95f, t));
            return 1.6f + north * (4 + Mathf.Abs(Mathf.Sin(t * 25 + side * 3)) * 8) + Mathf.Sin(t * 20 + side) * .5f;
        }
        static Vector3 Surface(float t, float side)
        { return new Vector3(Spine(t) + side * Width(t), Ground(t, side), (t - .5f) * 125); }

        void BuildTerrain()
        {
            var land = new Shape(); const int rows = 55, cols = 10;
            for (int z = 0; z < rows; z++) for (int x = 0; x < cols; x++)
            {
                float t = z / (float)rows, next = (z + 1) / (float)rows;
                float side = x / (float)cols * 2 - 1, sideNext = (x + 1) / (float)cols * 2 - 1;
                Vector3 a = Surface(t, side), b = Surface(next, side), c = Surface(next, sideNext), d = Surface(t, sideNext);
                float slope = Mathf.Abs(a.y - b.y) + Mathf.Abs(a.y - d.y);
                int color = slope > 2.3f ? 7 : (t > .7f ? 3 : (x % 3 == 0 ? 6 : 5));
                land.Quad(a, b, c, d, color, true);
            }
            for (int z = 0; z < rows; z++) foreach (float edge in new[] { -1f, 1f })
            {
                Vector3 a = Surface(z / (float)rows, edge), b = Surface((z + 1) / (float)rows, edge);
                Vector3 downA = new Vector3(a.x, -2, a.z), downB = new Vector3(b.x, -2, b.z);
                if (edge < 0) land.Quad(a, downA, downB, b, 1); else land.Quad(a, b, downB, downA, 1);
            }
            foreach (float end in new[] { 0f, 1f })
            {
                Vector3 a = Surface(end, -1), b = Surface(end, 1);
                if (end == 0) land.Quad(a, b, new Vector3(b.x, -2, b.z), new Vector3(a.x, -2, a.z), 1);
                else land.Quad(b, a, new Vector3(a.x, -2, a.z), new Vector3(b.x, -2, b.z), 1);
            }
            Create("Raised illustrative terrain with height and slope palette", land);
            var sea = new Shape(); sea.Box(new Vector3(0, -2.8f, 0), new Vector3(110, 1, 150), 16);
            Create("Water-colour diorama plinth", sea);
        }

        void BuildCanopies()
        {
            // Overworld deliberately has no grass: one combined mesh of rounded silhouettes.
            var grove = new Shape();
            for (int i = 0; i < 38; i++)
            {
                float t = .1f + i / 38f * .8f;
                float side = i % 2 == 0 ? -.57f : .63f;
                Vector3 at = Surface(t, side);
                grove.Box(at + Vector3.up * .65f, new Vector3(.3f,1.3f,.3f),18);
                grove.Canopy(at + Vector3.up * 2, new Vector3(1.5f,1.9f,1.45f),i % 4 == 0 ? 6 : 3);
            }
            Create("Rounded overworld canopy clusters — no detailed grass",grove);
        }

        void BuildChapters()
        {
            TextAsset json = Resources.Load<TextAsset>("Regions");
            Registry registry = json != null ? JsonUtility.FromJson<Registry>(json.text) : null;
            if (registry == null || registry.tourismChapters == null) return;
            foreach (Chapter chapter in registry.tourismChapters)
            {
                float t = Mathf.Clamp01(chapter.mapZ), side = Mathf.Clamp((chapter.mapX - .5f) * 1.6f, -.7f, .7f);
                Vector3 p = Surface(t, side);
                var marker = new Shape(); marker.Box(new Vector3(0, 1.5f, 0), new Vector3(.55f, 3, .55f), 18);
                marker.Pyramid(new Vector3(0, 3.2f, 0), 1.7f, 1.7f, chapter.status == "demo" ? 10 : 9);
                GameObject obj = Create("Chapter " + chapter.id + " — " + chapter.status, marker);
                obj.transform.localPosition = p;
                var collider = obj.AddComponent<SphereCollider>(); collider.center = new Vector3(0, 2.5f, 0); collider.radius = 2.3f;
                pins.Add(new Pin { chapter = chapter, root = obj.transform, hit = collider });
                var landmark = new Shape();
                if (chapter.id == "ha-giang")
                    for (int i = 0; i < 3; i++) landmark.Pyramid(new Vector3(-5 + i * 2.6f, 0, 1), 2.3f, 4 + i, 7);
                else if (chapter.id == "hue")
                {
                    landmark.Box(new Vector3(-4, 1, 0), new Vector3(5, 2, 2.5f), 9);
                    landmark.Pyramid(new Vector3(-4, 2, 0), 3.2f, 1.3f, 17);
                }
                else if (chapter.id == "da-lat")
                    for (int i = 0; i < 3; i++)
                    {
                        Vector3 at = new Vector3(-4 - i * 1.7f, 0, i);
                        landmark.Box(at + Vector3.up, new Vector3(.35f, 2, .35f), 18);
                        landmark.Pyramid(at + Vector3.up * 1.5f, 1.5f, 3, 2);
                    }
                else
                {
                    landmark.Box(new Vector3(-4, .3f, 0), new Vector3(1.4f, .5f, 4), 18);
                    landmark.Pyramid(new Vector3(-4, .5f, 0), 1.1f, 2.2f, 9);
                }
                GameObject icon = Create("Illustrative landmark " + chapter.id, landmark); icon.transform.localPosition = p;
            }
        }

        Vector3 RoutePoint(float t)
        {
            // Miniature route follows the illustrative raised spine, not a real road/GPS route.
            return Surface(Mathf.Lerp(.08f, .86f, t), .05f) + Vector3.up * .3f;
        }
        void BuildRoute()
        {
            var path = new Shape();
            for (int i = 0; i < 100; i++)
            {
                Vector3 a = RoutePoint(i / 100f), b = RoutePoint((i + 1) / 100f);
                path.Quad(a + Vector3.left * .6f, b + Vector3.left * .6f, b + Vector3.right * .6f, a + Vector3.right * .6f, 19);
            }
            Create("Illustrative journey route", path);
        }
        void BuildClouds()
        {
            for (int i = 0; i < 5; i++)
            {
                var cloud = new Shape();
                for (int k = 0; k < 3; k++) cloud.Box(new Vector3(k * 2, Mathf.Sin(k) * .3f, 0), new Vector3(4, 1, 2.8f), 30);
                GameObject obj = Create("Slow drifting painted cloud", cloud);
                Vector3 p = new Vector3(-20 + i * 10, 20 + i % 2 * 4, -45 + i * 22);
                clouds.Add(obj.transform); cloudOrigins.Add(p); obj.transform.localPosition = p;
            }
        }

        public void Show(bool visible)
        { shown = visible; if (contents != null) contents.gameObject.SetActive(visible); }
        public void SetFocus(string chapterId)
        {
            foreach (Pin pin in pins)
            {
                bool selected = pin.chapter.id == chapterId; pin.root.localScale = Vector3.one * (selected ? 1.25f : 1);
                if (selected) { FocusedChapterId = chapterId; targetFocus = pin.root.position; }
            }
        }
        public void Orbit(Vector2 delta)
        { if (!shown) return; yaw = Mathf.Repeat(yaw + delta.x * .25f, 360); pitch = Mathf.Clamp(pitch - delta.y * .2f, 28, 75); }
        public void Zoom(float delta) { if (shown) radius = Mathf.Clamp(radius - delta * 8, 38, 175); }
        public bool TrySelect(Camera camera, Vector2 screenPosition)
        {
            if (!shown || camera == null) return false;
            Ray ray = camera.ScreenPointToRay(screenPosition);
            Pin nearest = null; float nearestDistance = float.PositiveInfinity;
            foreach (Pin pin in pins) if (pin.hit.Raycast(ray, out RaycastHit hit, 500) && hit.distance < nearestDistance)
            { nearest = pin; nearestDistance = hit.distance; }
            if (nearest == null) return false;
            SetFocus(nearest.chapter.id); ChapterSelected?.Invoke(nearest.chapter.id); return true;
        }
        public void UpdateCamera(Camera camera)
        {
            if (!shown || camera == null) return;
            focus = Vector3.Lerp(focus, targetFocus, 1 - Mathf.Exp(-6 * Time.unscaledDeltaTime));
            Quaternion rotation = Quaternion.Euler(pitch, yaw, 0);
            camera.transform.SetPositionAndRotation(focus + rotation * Vector3.back * radius, rotation);
        }
        void Update()
        {
            if (!shown || miniature == null) return;
            progress = Mathf.Repeat(progress + Time.unscaledDeltaTime * .025f, 1);
            Vector3 p = RoutePoint(progress), ahead = RoutePoint(Mathf.Min(progress + .005f, 1));
            miniature.localPosition = p;
            if ((ahead - p).sqrMagnitude > .0001f) miniature.localRotation = Quaternion.LookRotation(ahead - p, Vector3.up);
            for (int i = 0; i < clouds.Count; i++) clouds[i].localPosition = cloudOrigins[i] + Vector3.right * Mathf.Sin(Time.unscaledTime * .06f + i) * 7;
        }
        GameObject Create(string title, Shape shape)
        {
            GameObject obj = new GameObject(title); obj.transform.SetParent(contents, false);
            Mesh mesh = shape.Mesh(); ownedMeshes.Add(mesh); obj.AddComponent<MeshFilter>().sharedMesh = mesh;
            var renderer = obj.AddComponent<MeshRenderer>(); renderer.sharedMaterial = material; renderer.shadowCastingMode = ShadowCastingMode.Off;
            return obj;
        }
        void OnDestroy()
        { foreach (Mesh mesh in ownedMeshes) if (mesh != null) Destroy(mesh); if (contents != null) Destroy(contents.gameObject); }

        sealed class Shape
        {
            readonly List<Vector3> vertices = new List<Vector3>(); readonly List<int> indices = new List<int>();
            readonly List<Vector2> uvs = new List<Vector2>(); readonly List<Color> colors = new List<Color>();
            void Triangle(Vector3 a, Vector3 b, Vector3 c, int id, bool terrain = false)
            {
                int first = vertices.Count; vertices.Add(a); vertices.Add(b); vertices.Add(c);
                Vector2 uv = new Vector2((id % 8 + .5f) / 8, (id / 8 + .5f) / 8);
                Vector3 faceNormal = Vector3.Cross(b - a, c - a).normalized;
                float height = Mathf.InverseLerp(0, 15, (a.y + b.y + c.y) / 3);
                Color tint = terrain ? Color.Lerp(new Color(.87f, .94f, .84f), new Color(1.04f, 1.01f, .91f), height) : Color.white;
                if (terrain && faceNormal.y < .65f) tint *= new Color(.86f, .79f, .84f);
                // Diorama height is local illustrative data: do not reuse the road material's world-height range.
                tint.a = 0;
                for (int i = 0; i < 3; i++) { indices.Add(first + i); uvs.Add(uv); colors.Add(tint); }
            }
            public void Quad(Vector3 a, Vector3 b, Vector3 c, Vector3 d, int id, bool terrain = false)
            { Triangle(a, b, c, id, terrain); Triangle(a, c, d, id, terrain); }
            public void Box(Vector3 p, Vector3 size, int id)
            {
                Vector3 h = size * .5f;
                Vector3 a = p + new Vector3(-h.x, -h.y, -h.z), b = p + new Vector3(h.x, -h.y, -h.z), c = p + new Vector3(h.x, -h.y, h.z), d = p + new Vector3(-h.x, -h.y, h.z);
                Vector3 up = Vector3.up * size.y;
                Quad(a, a + up, b + up, b, id); Quad(b, b + up, c + up, c, id); Quad(c, c + up, d + up, d, id); Quad(d, d + up, a + up, a, id); Quad(a + up, d + up, c + up, b + up, id); Quad(d, a, b, c, id);
            }
            public void Canopy(Vector3 center, Vector3 size, int id)
            {
                const int rings = 5, sides = 8;
                for(int r=0;r<rings;r++) for(int side=0;side<sides;side++)
                {
                    float a=-Mathf.PI*.5f+r*Mathf.PI/rings, b=a+Mathf.PI/rings;
                    float u=side*Mathf.PI*2/sides, v=(side+1)*Mathf.PI*2/sides;
                    Quad(center+Vector3.Scale(size,new Vector3(Mathf.Cos(a)*Mathf.Cos(u),Mathf.Sin(a),Mathf.Cos(a)*Mathf.Sin(u))),
                         center+Vector3.Scale(size,new Vector3(Mathf.Cos(b)*Mathf.Cos(u),Mathf.Sin(b),Mathf.Cos(b)*Mathf.Sin(u))),
                         center+Vector3.Scale(size,new Vector3(Mathf.Cos(b)*Mathf.Cos(v),Mathf.Sin(b),Mathf.Cos(b)*Mathf.Sin(v))),
                         center+Vector3.Scale(size,new Vector3(Mathf.Cos(a)*Mathf.Cos(v),Mathf.Sin(a),Mathf.Cos(a)*Mathf.Sin(v))),id);
                }
            }
            public void Pyramid(Vector3 p, float radius, float height, int id)
            {
                Vector3 tip = p + Vector3.up * height;
                for (int i = 0; i < 6; i++)
                {
                    float a = i * Mathf.PI / 3, b = (i + 1) * Mathf.PI / 3;
                    Triangle(p + new Vector3(Mathf.Cos(a), 0, Mathf.Sin(a)) * radius, tip, p + new Vector3(Mathf.Cos(b), 0, Mathf.Sin(b)) * radius, id);
                }
            }
            public Mesh Mesh()
            {
                var mesh = new Mesh { name = "Original journey diorama geometry" };
                if (vertices.Count > 65535) mesh.indexFormat = IndexFormat.UInt32;
                mesh.SetVertices(vertices); mesh.SetTriangles(indices, 0); mesh.SetUVs(0, uvs); mesh.SetColors(colors); mesh.RecalculateNormals(); mesh.RecalculateBounds(); return mesh;
            }
        }
    }
}
