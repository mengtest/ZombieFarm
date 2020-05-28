using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;

namespace World.View
{
    public class AssetCacher
    {
        public const int GRP_ASSET_LIMIT = 50;
        private static bool m_Outline = true;
        public static bool outline { get { return m_Outline; } }

        private static bool m_Pointlit = true;
        public static bool pointlit { get { return m_Pointlit; } }

        public static readonly MaterialSet HumanUIMats = new MaterialSet("HumanMat UI");
        public readonly MaterialSet SelfMats = new MaterialSet("SelfMat");
        public readonly MaterialSet HumanMats = new MaterialSet("HumanMat");
        public readonly MaterialSet RoleMats = new MaterialSet("RoleMat");
        public readonly MaterialSet BuildMats = new MaterialSet("BuildMat");
        public readonly MaterialSet UnitMats = new MaterialSet("UnitMat");
        public readonly MaterialSet PlantMats = new MaterialSet("PlantMat");
        public readonly MaterialSet WallMats = new MaterialSet("WallMat");
        public readonly MaterialSet TreeMats = new MaterialSet("TreeMat");

        private readonly Dictionary<string, MaterialSet> m_MatSetDict = new Dictionary<string, MaterialSet>();

        public MaterialSet GetMaterialSet(Material mat)
        {
            if (mat == null) return null;
                
            string matName = mat.name;
            MaterialSet matSet;
            if (!m_MatSetDict.TryGetValue(matName, out matSet)) {
                matSet = new MaterialSet(mat);
                m_MatSetDict.Add(matName, matSet);
            }

            return matSet;
        }

        private readonly Dictionary<string, Mesh> m_CombinedMeshes = new Dictionary<string, Mesh>();
        public void CacheCombined(string meshName, Mesh mesh)
        {
            if (mesh == null) {
                LogMgr.W("CacheCombined: try to cache a null mesh with name[{0}].", meshName);
                return;
            }

            if (m_CombinedMeshes.ContainsKey(meshName)) {
                LogMgr.W("CacheCombined: mesh[{0}] is alreay cached.", meshName);
                return;
            }

            m_CombinedMeshes.Add(meshName, mesh);
        }

        public Mesh GetCombined(string meshName)
        {
            Mesh mesh;
            m_CombinedMeshes.TryGetValue(meshName, out mesh);
            return mesh;
        }

        public void Clear()
        {
            SelfMats.Clear();
            HumanMats.Clear();
            RoleMats.Clear();
            BuildMats.Clear();
            UnitMats.Clear();
            PlantMats.Clear();
            WallMats.Clear();
            TreeMats.Clear();

            foreach (var value in m_MatSetDict.Values) {
                value.Clear();
            }
            m_MatSetDict.Clear();

            foreach (var mesh in m_CombinedMeshes.Values) {
                if (mesh) Object.Destroy(mesh);
            }
        }

        public void SetPointlit(bool value)
        {
            m_Pointlit = value;

            HumanUIMats.SetPointlit();
            SelfMats.SetPointlit();
            HumanMats.SetPointlit();
            RoleMats.SetPointlit();
            BuildMats.SetPointlit();
            UnitMats.SetPointlit();
            PlantMats.SetPointlit();
            WallMats.SetPointlit();            
            TreeMats.SetPointlit();

            foreach (var v in m_MatSetDict.Values) {
                v.SetPointlit();
            }
        }

        public void SetOutline(bool value)
        {
            m_Outline = value;

            HumanUIMats.SetOutline();
            SelfMats.SetOutline();
            HumanMats.SetOutline();
            RoleMats.SetOutline();
            BuildMats.SetOutline();
            UnitMats.SetOutline();
            PlantMats.SetOutline();
            WallMats.SetOutline();
            TreeMats.SetOutline();

            foreach (var v in m_MatSetDict.Values) {
                v.SetOutline();
            }
        }
    }
}
