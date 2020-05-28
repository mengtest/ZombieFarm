using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace World.View
{
	public static class StageEditTool
	{
		[MenuItem("Assets/关卡工具/Snap Grass")]
		private static void SnapGrasses()
		{
			var root = Selection.activeGameObject;
			if (root == null) return;

			var list = new List<Transform>();
			foreach (Transform t in root.transform) {
				var pos = t.position;
				pos.x = Mathf.Round(pos.x / 2) * 2;
				pos.z = Mathf.Round(pos.z / 2) * 2;
				t.position = pos;
				t.name = string.Format("grass({0},{1})", pos.x, pos.z);
				list.Add(t);
			}

			list.Sort((a, b) => {
				Vector3 apos = a.position, bpos = b.position;
				int ax = (int)apos.x, bx = (int)bpos.x;
				if (ax != bx) return ax - bx;
				return (int)apos.z - (int)bpos.z;
			});

			Vector3 prevPos = Vector3.one / 2;
			for (int i = 0; i < list.Count; i++) {
				list[i].SetSiblingIndex(i);
				var pos = list[i].position;
				if (pos == prevPos) {
					LogMgr.W("出现重复位置:{0}", prevPos);
				}

				prevPos = pos;
			}
		}
	}
}
