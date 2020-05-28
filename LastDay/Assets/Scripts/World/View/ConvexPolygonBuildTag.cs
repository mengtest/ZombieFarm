using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace World.View
{
    public class ConvexPolygonBuildTag : MonoBehaviour
    {
        [SerializeField, NavMeshArea]
        protected int m_Area = 4;

        [SerializeField]
        private Vector3[] m_Points = new Vector3[] {
            Vector3.zero, Vector3.right, Vector3.forward,
        };

        public Vector3[] points { get { return m_Points; } }

        protected virtual void Start()
        {
            GenerateMesh();
            var tag = (NavMeshBuildTag)gameObject.NeedComponent(typeof(NavMeshBuildTag));
            tag.area = m_Area;
        }

        protected MeshFilter GenerateMesh()
        {
            // 生成寻路标签模型
            var filter = (MeshFilter)gameObject.NeedComponent(typeof(MeshFilter));
            if (filter.sharedMesh == null) {
                var mesh = new Mesh() { name = name };
                var v3s = new List<Vector3>();
                for (int i = 0; i < m_Points.Length; ++i) {
                    var p = m_Points[i];
                    v3s.Add(new Vector3(p.x, 0, p.z));
                }
                mesh.SetVertices(v3s); ;

                var triangles = new List<int>();
                for (int i = m_Points.Length - 1; i > 1; --i) {
                    triangles.Add(0);
                    triangles.Add(i);
                    triangles.Add(i - 1);
                }
                mesh.SetTriangles(triangles, 0);
                mesh.RecalculateNormals();
                filter.sharedMesh = mesh;
            }

            return filter;
        }

#if UNITY_EDITOR
        protected virtual void OnDrawGizmosSelected()
        {
            
        }
#endif
    }
}
