using System;
using System.Collections.Generic;
namespace VietTrail.Core
{
    [Serializable] public sealed class JourneyOptions
    {
        public float music = 0.65f;
        public float sfx = 0.8f;
        public int quality = 1;
        public int bikeColor;
    }
    [Serializable] public sealed class JourneyState
    {
        public int version = 1;
        public float meters = 8;
        public float lane = 1.2f;
        public List<string> visited = new List<string>();
        public JourneyOptions options = new JourneyOptions();
    }
}
