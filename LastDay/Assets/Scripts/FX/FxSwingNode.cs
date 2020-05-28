using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    public class FxSwingNode : FxTiming
    {
        [System.Serializable]
        private class NodeInfo
        {
            [SerializeField]
            private Transform m_Node;
            [SerializeField]
            private Transform m_PosTar;
            [SerializeField]
            private Transform m_RotTar;
            [SerializeField]
            private float m_Speed;
            //private Transform m_Head;

            private Vector3 m_Prev;

            public void Init(Transform head)
            {
                //m_Head = head;
                m_Prev = m_Node.position;
            }

            public void Update(float deltaTime)
            {
                var movespeed = m_Speed;

                var xx = Mathf.Lerp(m_Prev.x, m_PosTar.position.x, movespeed * deltaTime);
                var yy = Mathf.Lerp(m_Prev.y, m_PosTar.position.y, movespeed * deltaTime);
                var zz = Mathf.Lerp(m_Prev.z, m_PosTar.position.z, movespeed * deltaTime);

                m_Prev = new Vector3(xx, yy, zz);
                m_Node.position = m_Prev;
                m_Node.rotation = Quaternion.Slerp(m_Node.rotation, m_RotTar.rotation, movespeed * deltaTime);
            }
        }

        [SerializeField]
        private NodeInfo[] m_Nodes;

        private void Start()
        {
            for (int i = 0; i < m_Nodes.Length; ++i) {
                m_Nodes[i].Init(transform);
            }
        }

        private void LateUpdate()
        {
            for (int i = 0; i < m_Nodes.Length; ++i) {
                m_Nodes[i].Update(deltaTime);
            }
        }

    }
}
