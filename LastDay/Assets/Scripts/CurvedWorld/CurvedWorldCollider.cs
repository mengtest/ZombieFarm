using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using VacuumShaders.CurvedWorld;

/// <summary>
/// 使用CurvedWorld插件时，同步挂载的Collider位置
/// </summary>
[RequireComponent(typeof(Collider))]
public class CurvedWorldCollider : MonoBehaviour
{
    [SerializeField]
    //private BEND_TYPE m_Bend;

    private Collider m_Cld;
    // Use this for initialization
    void Start()
    {
        m_Cld = GetComponent(typeof(Collider)) as Collider;
    }

    //private void Update()
    //{
    //    if (m_Cld) {
    //        var cwc = CurvedWorld_Controller.get;
    //        if (cwc) {
    //            var pos = cwc.TransformPoint(transform.position, m_Bend);

    //            var sphereCld = m_Cld as SphereCollider;
    //            if (sphereCld) {
    //                sphereCld.center = pos - transform.position;
    //                return;
    //            }
    //        }
    //    }
    //}
    
}
