using UnityEngine;
using System.Collections;

public static class MatTools
{
    public static void CopyColor(this Material self, int nameID, Material tarMat)
    {
        self.SetColor(nameID, tarMat.GetColor(nameID));
    }
    public static void CopyInt(this Material self, int nameID, Material tarMat)
    {
        self.SetInt(nameID, tarMat.GetInt(nameID));
    }
    public static void CopyFloat(this Material self, int nameID, Material tarMat)
    {
        self.SetFloat(nameID, tarMat.GetFloat(nameID));
    }
    public static void CopyTexture(this Material self, int nameID, Material tarMat)
    {
        self.SetTexture(nameID, tarMat.GetTexture(nameID));
    }
    public static void TryCopyTexture(this Material self, int nameID, Material tarMat)
    {
        if (self.HasProperty(nameID) && tarMat.HasProperty(nameID)) {
            self.CopyTexture(nameID, tarMat);
        }
    }
    
    public static void SetKeyword(this Material self, string keyword, bool enabled)
    {
        if (enabled) {
            self.EnableKeyword(keyword);
        } else {
            self.DisableKeyword(keyword);
        }
    }
    
    public static void TryCopyTexture(this MaterialPropertyBlock self, int nameID, Material tarMat)
    {
        if (tarMat && tarMat.HasProperty(nameID)) {
            var tex = tarMat.GetTexture(nameID);
            if (tex != null) self.SetTexture(nameID, tex);
        }
    }
}

namespace UnityEngine.Rendering
{
    public enum DepthTest { Off, On }
}
