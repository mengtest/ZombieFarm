using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public static class MeshTools
{
    public static void SetColor(this Renderer self, int nameId, Color color)
    {
        if (self) {
            var props = MaterialPropertyTool.Begin(self);
            props.SetColor(nameId, color);
            MaterialPropertyTool.Finish();
        }
    }
    
    public static Color GetColor(this Renderer self, int nameId)
    {
        Color color = Color.clear;
        if (self) {
            var props = MaterialPropertyTool.Begin(self);
            color = props.GetColor(nameId);
            MaterialPropertyTool.Finish();
        }

        return color;
    }

    public static void ClearPropertyBlock(this Renderer self)
    {
        if (self) {
            var props = MaterialPropertyTool.Begin(self);
            props.Clear();
            MaterialPropertyTool.Finish();
        }
    }
}
