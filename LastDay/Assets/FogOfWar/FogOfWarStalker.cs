using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;

/// <summary>
/// 潜行者
/// </summary>
public class FogOfWarStalker : MonoBehaviour, ILateTick
{
    protected const float REQUEST_DURA = 0.3f;

    protected float m_RequestTime;

    protected bool m_Visible;

    private void OnEnable()
    {
        m_Visible = FogOfWarEffect.IsVisibleInMap(transform.position);
        SetVisible(m_Visible);
        TickManager.Add(this);
    }

    private void OnDisable()
    {
        TickManager.Remove(this);
    }

    protected virtual void SetVisible(bool visible)
    {
        for (int i = 0; i < transform.childCount; i++) {
            transform.GetChild(i).gameObject.SetActive(visible);
        }
    }
    
    bool ITickBase.ignoreTimeScale {
        get { return false; }
    }

    void ILateTick.LateTick(float deltaTime)
    {
        m_RequestTime += deltaTime;
        if (m_RequestTime > REQUEST_DURA) {
            m_RequestTime = 0;
            bool visible = FogOfWarEffect.IsVisibleInMap(transform.position);
            if (m_Visible != visible) {
                m_Visible = visible;
                SetVisible(visible);
            }
        }
    }
}
