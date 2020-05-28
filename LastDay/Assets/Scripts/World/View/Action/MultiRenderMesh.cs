using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using World.Control;

namespace World.View
{
	public class MultiRenderMesh : MonoBehaviour, IInitRender, ISkinProperty
	{
        [SerializeField] protected Renderer m_Master;
		[SerializeField] protected Renderer[] m_SubSkins;

		protected void InitRenderer(Renderer rdr, Material mat)
		{
			var props = MaterialPropertyTool.Begin(rdr);
			props.TryCopyTexture(ShaderIDs.MainTex, rdr.sharedMaterial);
			props.SetColor(ShaderIDs.Color, rdr.sharedMaterial.GetColor(ShaderIDs.Color));
			MaterialPropertyTool.Finish();

			if (mat) rdr.sharedMaterial = mat;
		}
		
		public virtual void InitRender()
		{
            foreach (var rdr in m_SubSkins) {
				InitRenderer(rdr, m_Master.sharedMaterial);
			}
		}

        public virtual void GetSkins(List<Component> skins)
        {
            skins.Add(m_Master);
            skins.AddRange(m_SubSkins);
        }
	}
}
