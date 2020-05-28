using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MEC;

namespace World.View
{
    public class MapGenerate : MonoBehaviour
    {
        [SerializeField, AssetRef(null, typeof(MapData))]
        private string m_MapPath;
        
        [SerializeField]
        private Color[] m_Steps = new Color[] { Color.white };

        [SerializeField]
        private Renderer m_Renderer;

        private Texture2D m_MapTex;
        
        private void Start()
        {
            Timing.RunCoroutine(LoadMapTex());

        }

        private IEnumerator<float> LoadMapTex()
        {
            while (AssetsMgr.A == null) yield return Timing.WaitForOneFrame;

            if (this && isActiveAndEnabled) {
                AssetsMgr.A.LoadAsync(typeof(MapData), m_MapPath);
                while (!AssetsMgr.A.Loader.IsLoaded(m_MapPath)) yield return Timing.WaitForOneFrame;

                var mapData = AssetsMgr.A.Load(typeof(MapData), m_MapPath) as MapData;
                mapData.BuildTexture(ref m_MapTex, m_Steps);
                
                m_Renderer.material.mainTexture = m_MapTex;
                m_Renderer.transform.localScale = new Vector3(mapData.width, mapData.height, 1);
            }
        }

        private void OnDestroy()
        {
            Destroy(m_Renderer.material);
            Destroy(m_MapTex);
        }
    }
}
