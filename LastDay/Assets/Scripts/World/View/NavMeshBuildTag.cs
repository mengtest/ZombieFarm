using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace World.View
{
    public class NavMeshBuildTag : MonoBehaviour
    {
        public static List<NavMeshBuildTag> m_Tags = new List<NavMeshBuildTag>();

        [SerializeField, NavMeshArea]
        private int m_Area;
        public int area { get { return m_Area; } set { m_Area = value; } }

        [SerializeField]
        private NavMeshBuildSourceShape m_Shape = NavMeshBuildSourceShape.Mesh;

        private void OnEnable()
        {
            m_Tags.Add(this);
        }

        private void OnDisable()
        {
            m_Tags.Remove(this);
        }

        public bool GenBuildSource(ref NavMeshBuildSource source)
        {
            source.shape = m_Shape;
            source.area = m_Area;
            switch (m_Shape) {
                case NavMeshBuildSourceShape.Mesh:
                    var filter = GetComponent(typeof(MeshFilter)) as MeshFilter;
                    if (filter && filter.sharedMesh) {
                        source.sourceObject = filter.sharedMesh;
                        source.transform = filter.transform.localToWorldMatrix;
                        return true;
                    }
                    break;
                case NavMeshBuildSourceShape.Box:
                case NavMeshBuildSourceShape.ModifierBox:
                    source.transform = Matrix4x4.TRS(transform.position, transform.rotation, Vector3.one);
                    source.size = transform.lossyScale;
                    return true;
                default: break;
            }

            return false;
        }
        
        // Collect all the navmesh build sources for enabled objects tagged by this component
        public static void Collect(ref List<NavMeshBuildSource> sources)
        {
            sources.Clear();
            foreach (var tag in m_Tags) {
                if (tag != null) {
                    var source = new NavMeshBuildSource();
                    if (tag.GenBuildSource(ref source)) {
                        sources.Add(source);
                    }
                }
            }
        }

        private void OnDrawGizmosSelected()
        {
            var defMatrix = Gizmos.matrix;
            Gizmos.matrix = transform.localToWorldMatrix;
            switch (m_Shape) {
                case NavMeshBuildSourceShape.Box:
                case NavMeshBuildSourceShape.ModifierBox:
                    Gizmos.DrawCube(Vector3.zero, Vector3.one);
                    break;
                case NavMeshBuildSourceShape.Capsule:
                case NavMeshBuildSourceShape.Sphere:
                    Gizmos.DrawWireSphere(Vector3.zero, transform.lossyScale.x);
                    break;
                case NavMeshBuildSourceShape.Mesh:
                    var filter = GetComponent(typeof(MeshFilter)) as MeshFilter;
                    if (filter && filter.sharedMesh) {
                        Gizmos.DrawMesh(filter.sharedMesh);
                    }
                    break;
                default: break;
            }
            Gizmos.matrix = defMatrix;
        }
    }
}
