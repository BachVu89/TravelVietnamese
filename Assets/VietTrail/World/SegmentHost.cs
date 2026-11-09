using System.Collections.Generic;
using UnityEngine;

namespace VietTrail.World
{
    /// <summary>Owns generated mesh lifetimes. Road collision is built synchronously before play.</summary>
    public sealed class SegmentHost : MonoBehaviour
    {
        public const float SegmentMeters = 96f;
        readonly Dictionary<int, GameObject> live = new Dictionary<int, GameObject>();
        Material palette;
        int current = -1;
        public int LiveCount { get { return live.Count; } }

        public void WarmStart(float meters, Material worldMat)
        {
            Clear();
            palette = worldMat;
            current = -1;
            Follow(meters);
            Physics.SyncTransforms();
        }

        public void Follow(float meters)
        {
            if (palette == null) return;
            int last = Mathf.CeilToInt(TrailPath.Length / SegmentMeters) - 1;
            int station = Mathf.Clamp(Mathf.FloorToInt(Mathf.Clamp(meters, 0f, TrailPath.Length) / SegmentMeters), 0, last);
            if (current == station && live.Count != 0) return;
            current = station;
            int first = Mathf.Max(0, station - 1);
            int end = Mathf.Min(last, station + 3);
            var remove = new List<int>();
            foreach (int index in live.Keys)
                if (index < first || index > end) remove.Add(index);
            foreach (int index in remove)
            {
                Release(live[index]);
                live.Remove(index);
            }
            for (int index = first; index <= end; index++)
            {
                if (live.ContainsKey(index)) continue;
                var chunk = new GameObject("Route segment " + index);
                chunk.transform.SetParent(transform, false);
                SegmentPainter.Build(chunk, index * SegmentMeters,
                    Mathf.Min((index + 1) * SegmentMeters, TrailPath.Length), palette);
                live.Add(index, chunk);
            }
        }

        static void Release(GameObject chunk)
        {
            // Destroy is deferred during play: immediately deactivate collision/render first.
            chunk.SetActive(false);
            foreach (MeshCollider collider in chunk.GetComponentsInChildren<MeshCollider>(true))
                collider.sharedMesh = null;
            foreach (MeshFilter filter in chunk.GetComponentsInChildren<MeshFilter>(true))
            {
                Mesh mesh = filter.sharedMesh;
                if (mesh != null)
                {
                    if (Application.isPlaying) Object.Destroy(mesh);
                    else Object.DestroyImmediate(mesh);
                }
            }
            if (Application.isPlaying) Object.Destroy(chunk);
            else Object.DestroyImmediate(chunk);
        }

        void Clear()
        {
            foreach (GameObject chunk in live.Values) if (chunk != null) Release(chunk);
            live.Clear();
        }

        void OnDestroy() { Clear(); }
    }
}
