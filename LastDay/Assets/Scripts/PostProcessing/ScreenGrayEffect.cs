using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenGrayEffect : MonoBehaviour
{
    public Shader shader;
    Material material;

    [Range(0, 1.0f)]
    public float m_fGrayFactor;

    private float m_fEndTime = 0;
    private float m_fDuration = 0;

    public void BegineScreenGrayFx(float duration)
    {
        Init();
        m_fGrayFactor = 0;
        m_fDuration = duration;
        m_fEndTime = Time.time + duration;
        enabled = true;
    }

    public void StopScreenGrayFx()
    {
        m_fGrayFactor = 0;
        m_fDuration = 0;
        m_fEndTime = 0;
        enabled = false;
    }

    public void SetGrayFactor(float _grayFactor)
    {
        m_fGrayFactor = _grayFactor;
    }

    private void Init()
    {
        if (material == null)
        {
            material = new Material(shader);
        }
    }

    void Awake()
    {
        Init();
    }

    void Update()
    {
        float lastTime = m_fEndTime - Time.time;
        if (lastTime > 0 && m_fDuration > 0)
        {
            SetGrayFactor(1f - (lastTime / m_fDuration));
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            //设置shader中的_GrayFactor参数
            material.SetFloat("_GrayFactor", m_fGrayFactor);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
