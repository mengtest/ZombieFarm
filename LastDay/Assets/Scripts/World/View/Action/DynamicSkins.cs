using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
	public class DynamicSkins : MultiRenderMesh, IPoolable
	{
		private List<Renderer> m_DynamicSkins = new List<Renderer>();

		public override void GetSkins(List<Component> skins)
		{
			base.GetSkins(skins);
			for (int i = 0; i < m_DynamicSkins.Count; ++i) {
				var skin = m_DynamicSkins[i];
				if (skin) skins.Add(skin);
			}
		}

        public void AddSkin(Renderer rdr, bool uniformMaterial)
        {
            if (!m_DynamicSkins.Contains(rdr)) {
                m_DynamicSkins.Add(rdr);
                InitRenderer(rdr, uniformMaterial ? m_Master.sharedMaterial : null);
            }

            var props = MaterialPropertyTool.Begin(m_Master);
            var color = props.GetColor(ShaderIDs.Color);
            MaterialPropertyTool.Finish();

            if (color != Color.clear) {
                props = MaterialPropertyTool.Begin(rdr);
                props.SetColor(ShaderIDs.Color, color);
                MaterialPropertyTool.Finish();
            }
        }

		public void RemoveSkin(Renderer rdr)
		{
			m_DynamicSkins.Remove(rdr);
		}

		void IPoolable.OnRestart()
		{
			
		}

		void IPoolable.OnRecycle()
		{
			m_DynamicSkins.Clear();
		}
	}

}
