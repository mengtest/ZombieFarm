//
//  FxStretched.cs
//  survive
//
//  Created by xingweizhen on 10/24/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    public class FxStretched : MonoBehaviour
    {
        private enum AXIS { N, Hori, Vert }
        private enum DIRECTION { X, Y, Z }

        [SerializeField]
        private AXIS axis;

        [SerializeField]
        private DIRECTION direction;

        [SerializeField]
        private Transform m_Camera;

        private Vector3 m_Look;
        // Update is called once per frame
        private void Update()
        {
            if (m_Camera) {
                var offset = m_Camera.position - transform.position;
                switch (axis) {
                    case AXIS.Hori:
                        m_Look = new Vector3(offset.x, offset.y, 0);
                        break;
                    case AXIS.Vert:
                        m_Look = new Vector3(offset.x, 0, offset.z);
                        break;                        
                    default: break;
                }

                switch (direction) {
                    case DIRECTION.X:
                        transform.right = m_Look.normalized;
                        break;
                    case DIRECTION.Y:
                        transform.up = m_Look.normalized;
                        break;
                    case DIRECTION.Z:
                        transform.forward = m_Look.normalized;
                        break;
                    default: break;
                }
            } else {
                if (Camera.main != null) {
                    m_Camera = Camera.main.transform;
                }
            }
        }

#if UNITY_EDITOR
        
#endif

    }
}
