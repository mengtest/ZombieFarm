using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;

/// <summary>
/// 视野数据-由于计算fov是在子线程操作，通过将视野数据以object类型参数传入，使用简单数据类型或结构体会产生装箱操作，因此将视野封装成类
/// </summary>
public class FOWFieldData
{
    private float m_RadiusSquare;
    public float radiusSquare {
        get {
            if (m_RadiusSquare < 0)
                m_RadiusSquare = radius * radius;
            return m_RadiusSquare;
        }
    }

    private float m_Radius;
    public float radius {
        get { return m_Radius; }
        set { if (m_Radius != value) { 
                m_Radius = value;
                m_RadiusSquare = -1;
            }
        }
    }

    public Vector3 position;    

    public FOWFieldData(Vector3 position, float radius)
    {
        this.position = position;
        this.radius = radius;
    }
}

/// <summary>
/// 探索者
/// </summary>
public class FogOfWarExplorer : MonoBehaviour, ITickable
{
    /// <summary>
    /// 视野半径
    /// </summary>
    [SerializeField]
    protected float m_Radius;
    
    protected Vector3 m_OriginPosition;

    protected FOWMapPos m_FowMapPos;

    protected FOWFieldData m_FieldData;

    protected bool m_IsInitialized;
    
    void Awake()
    {
        m_FieldData = new FOWFieldData(transform.position, GetRadius());
    }

    public virtual float GetRadius() { return m_Radius; }

    protected virtual Vector3 GetPos() { return transform.position; }

    bool ITickBase.ignoreTimeScale {
        get { return false; }
    }
    
    public virtual void Tick(float deltaTime)
    {
        if (!FogOfWarEffect.IsEffecting()) {
            m_IsInitialized = false;
            return;
        }

        var explorRad = GetRadius();

        if (explorRad <= 0)
            return;

        var dirty = false;

        var transPos = GetPos();

        if (!m_IsInitialized) {
            dirty = true;
            m_IsInitialized = true;
        }

        if (m_FieldData.radius != explorRad) {
            m_FieldData.radius = explorRad;
            dirty = true;
        }

        if (m_OriginPosition != transPos) {
            m_OriginPosition = transPos;
            var pos = FogOfWarEffect.WorldPositionToFOW(transPos);
            if (m_FowMapPos.x != pos.x || m_FowMapPos.y != pos.y) {
                m_FowMapPos = pos;
                m_FieldData.position = transPos;
                dirty = true;
            }
        }

        if (dirty) {
            //FogOfWarEffect.SetVisibleAtPosition(m_FieldData);
            //LogMgr.D("Update FOW @ {0}", transPos);
            FogOfWarEffect.UpdateFOWFieldData(m_FieldData);
        }
    }

    private void OnEnable()
    {
        TickManager.Add(this);
    }

    protected virtual void OnDisable()
    {
        FogOfWarEffect.ReleaseFOWFieldData(m_FieldData);
        TickManager.Remove(this);
    }

    void OnDestroy()
    {
        if (m_FieldData != null)
            FogOfWarEffect.ReleaseFOWFieldData(m_FieldData);
        m_FieldData = null;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, GetRadius());
    }
}
