//
//  LegacyAnimationCreator.cs
//  survive
//
//  Created by xingweizhen on 11/7/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LegacyAnimationCreator 
{
    [MenuItem("Custom/创建旧版本动画... &_6")]
    private static void CreateLegacyAnimtion()
    {
        if (Selection.activeGameObject) {
            var path = EditorUtility.SaveFilePanelInProject("创建旧版本动画", "New Animation", "anim", "122324");
            if (!string.IsNullOrEmpty(path)) {
                var anim = new AnimationClip();
                anim.legacy = true;
                AssetDatabase.CreateAsset(anim, path);

                var animtion = Selection.activeGameObject.GetComponent<Animation>();
                if (animtion == null) {
                    animtion = Selection.activeGameObject.AddComponent<Animation>();
                }
                animtion.clip = anim;
                animtion.AddClip(anim, anim.name);
            }
        }
    }
}
