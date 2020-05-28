using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class StageMapTexture : MonoSingleton<StageMapTexture>
    {
        [SerializeField]
        private Texture m_Texture;
        public Texture texture { get { return m_Texture; } }

        [SerializeField]
        private Vector4 m_Size;
        public Vector4 size { get { return m_Size; } }

        public Vector2 offset { get; private set; }

        public void Init(StageEdit edit)
        {
            var pos = edit.start.localPosition;
            var size = edit.size;
            offset = new Vector2(pos.x - m_Size.x + size.x / 2 - m_Size.z / 2, pos.z - m_Size.y + size.y / 2 - m_Size.w / 2);
        }
    }
}
