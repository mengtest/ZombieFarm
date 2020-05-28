using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public static class FindAssetHelper
{
	[MenuItem("Assets/资源/引用/Shader(FindAssetHelper)")]
	private static void FindFxMaterialsOfShader()
	{
		Shader shader = Selection.activeObject as Shader;
		if (shader == null) return;
		
		var abs = AssetDatabase.GetAllAssetBundleNames();
		foreach (var ab in abs) {
			if (ab.OrdinalIgnoreCaseStartsWith("fx/")) {
				foreach (var path in AssetDatabase.GetAssetPathsFromAssetBundle(ab)) {
					if (path.OrdinalIgnoreCaseEndsWith(".mat")) {
						var mat = AssetDatabase.LoadMainAssetAtPath(path) as Material;
						if (mat && mat.shader == shader) {
							Debug.LogFormat(mat, "{0}", path);
						}
					} else if (path.OrdinalIgnoreCaseEndsWith(".prefab")) {
						var o = AssetDatabase.LoadMainAssetAtPath(path) as GameObject;
						if (o != null) {
							var go = Object.Instantiate(o);
							var rdrs = go.GetComponentsInChildren(typeof(Renderer));
							foreach (Renderer rdr in rdrs) {
								foreach (var mat in rdr.sharedMaterials) {
									if (mat && mat.shader == shader) {
										Debug.LogFormat(o, "{0}/{1}", path, rdr.GetHierarchy(go.transform));
									}
								}
							}
 							Object.DestroyImmediate(go);
						}
					}
				}
			}
		}
		
		Debug.Log("Shader引用查找结束。");
	}
}