using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Shader Linker (Editor Only)")]
public class FxShaderLinker : MonoBehaviour
{

    // Use this for initialization
    private void Start()
    {
        AssetsMgr.AssignEditorShaders(gameObject);
    }    
}
