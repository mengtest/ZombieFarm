using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.Asset;

namespace World.View
{
	public class StageObject : MonoBehaviour, IDynamicAsset
	{
		private const string _OBJ_NAME = "__OBJ";
		
		[SerializeField, AssetRef] private string m_AssetPath;
		
		public  string assetPath { get { return m_AssetPath; } }

		public void OnAssetLoaded(Object asset)
		{
			var child = transform.Find(_OBJ_NAME);
			if (child != null) Destroy(child.gameObject);
			
			var prefab = asset as GameObject;
			if (prefab) {
				GoTools.NewChild(gameObject, prefab).name = _OBJ_NAME;
			}
		}

#if UNITY_EDITOR
        private bool m_Dirty;
		private void OnDrawGizmosSelected()
		{
			if (m_Dirty || !string.IsNullOrEmpty(m_AssetPath) && transform.Find(_OBJ_NAME) == null) {
                m_Dirty = false;
                LoadAssetAsync();
			}
		}

		private void LoadAssetAsync()
		{
			if (Application.isPlaying) return;
			
			var child = transform.Find(_OBJ_NAME);
			if (child != null) DestroyImmediate(child.gameObject);

			if (!string.IsNullOrEmpty(m_AssetPath)) {
				var asset = AssetLoader.EditorLoadAsset(typeof(GameObject), m_AssetPath) as GameObject;
				if (asset) {
					var go = GoTools.NewChild(gameObject, asset);
					go.name = _OBJ_NAME;

                    var hideFlags = HideFlags.DontSaveInBuild | HideFlags.DontSaveInEditor | HideFlags.HideInHierarchy;
					go.SetHideFlagsRecursively(hideFlags);
				}
			}
		}

        private void OnValidate()
        {
            m_Dirty = true;
        }
#endif       
    }
}
