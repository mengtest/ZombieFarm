using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    public class FxAnalyzer : MonoSingleton<FxAnalyzer>
    {
        public class Analyze
        {
            public string name { get; private set; }
            private int maxMesh, lmtMesh;
            private int maxParticle, lmtParticle;
            private int maxBetterTrail, lmtBetterTrail;
            private int maxUnityTrail, lmtUnityTrail;

            public Analyze(string name)
            {
                this.name = name;
                maxMesh = maxParticle = maxBetterTrail = maxUnityTrail = 0;
                lmtMesh = lmtParticle = lmtBetterTrail = lmtUnityTrail = 0;
            }

            public void SetLimit(int mesh, int particle, int betterTrail, int unityTrail)
            {
                this.lmtMesh = mesh;
                this.lmtParticle = particle;
                this.lmtBetterTrail = betterTrail;
                this.lmtUnityTrail = unityTrail;
            }

            public void SetMax(int mesh, int particle, int betterTrail, int unityTrail)
            {
                if (mesh > maxMesh) maxMesh = mesh;
                if (particle > maxParticle) maxParticle = particle;
                if (betterTrail > maxBetterTrail) maxBetterTrail = betterTrail;
                if (unityTrail > maxUnityTrail) maxUnityTrail = unityTrail;
            }

            public override string ToString()
            {
                return string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8}",
                name,
                maxMesh, lmtMesh,
                maxParticle, lmtParticle,
                maxBetterTrail, lmtBetterTrail,
                maxUnityTrail, lmtUnityTrail);
            }
        }

        private const string ANALYZE_FILE = ".fxanalyzer.csv";
        private const string ANALYZE_HEAD =
            "Name,Mesh,Total Mesh,Particle,Total Particle,BetterTrail,Total BetterTrail,UnityTrail,Total UnityTrail";

        private Dictionary<string, Analyze> m_Analyzies = new Dictionary<string, Analyze>();
        public Analyze GetAnalyze(string name)
        {
            Analyze analyze;
            if (!m_Analyzies.TryGetValue(name, out analyze)) {
                analyze = new Analyze(name);
                m_Analyzies.Add(name, analyze);
            }
            return analyze;
        }

        protected override void Awaking()
        {
            if (System.IO.File.Exists(ANALYZE_FILE)) {
                var lines = System.IO.File.ReadAllLines(ANALYZE_FILE);
                for (int i = 1; i < lines.Length; ++i) {
                    var segs = lines[i].Split(',');
                    if (segs.Length < 9) continue;
                    var analyze = new Analyze(segs[0]);
                    analyze.SetMax(int.Parse(segs[1]), int.Parse(segs[3]), int.Parse(segs[5]), int.Parse(segs[7]));
                    analyze.SetLimit(int.Parse(segs[2]), int.Parse(segs[4]), int.Parse(segs[6]), int.Parse(segs[8]));
                    m_Analyzies.Add(analyze.name, analyze);
                }
            }
        }

        private void OnDestroy()
        {
            var strbld = new System.Text.StringBuilder(ANALYZE_HEAD);
            strbld.AppendLine();
            foreach (var analyze in m_Analyzies.Values) {
                strbld.AppendLine(analyze.ToString());
            }
            System.IO.File.WriteAllText(ANALYZE_FILE, strbld.ToString());
        }
    }
}
