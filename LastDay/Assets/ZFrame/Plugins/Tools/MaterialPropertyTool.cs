using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialPropertyTool : Singleton<MaterialPropertyTool>
{
    private MaterialPropertyBlock m_Props = new MaterialPropertyBlock();

    private Renderer m_Rdr;
    private MaterialPropertyBlock _Begin(Renderer renderer)
    {
        m_Rdr = renderer;

        m_Props.Clear();
        m_Rdr.GetPropertyBlock(m_Props);
        return m_Props;
    }

    private void _Finish()
    {
        m_Rdr.SetPropertyBlock(m_Props);
        m_Props.Clear();

        m_Rdr = null;
    }

    public static MaterialPropertyBlock Begin(Renderer renderer)
    {
        return Instance._Begin(renderer);
    }
    
    public static void Finish()
    {
        Instance._Finish();
    }
}
