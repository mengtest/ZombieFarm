using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 与主摄像机保持位置一致
/// </summary>
[RequireComponent(typeof(Camera))]
public class ShadowProjector : MonoBehaviour
{
    [SerializeField]
    private Projector m_Proj;
    [SerializeField]
    public bool m_Auto;

    /// <summary>
    /// 制作投影的正交摄像机，一般与太阳光源位置一致
    /// </summary>
    private Camera m_ShadowCam;
    [SerializeField]
    private int m_TexSize = 1024;
    [SerializeField]
    private float m_Strength = 0.5f;
    [SerializeField]
    private string m_TexPath;

    RenderTexture m_Tex;
    Material m_Mat;

    private void GenTexture()
    {
        m_Tex = new RenderTexture(m_TexSize, m_TexSize, 0, RenderTextureFormat.ARGB32);
        m_Tex.name = "ShadowTex" + m_Tex.GetInstanceID();
        m_Tex.depth = 0;
        m_Tex.isPowerOfTwo = true;
        m_Tex.hideFlags = HideFlags.DontSave;
    }

    private void Awake()
    {
        m_ShadowCam = GetComponent<Camera>();

        if (string.IsNullOrEmpty(m_TexPath)) GenTexture();
    }

    [ContextMenu("初始化")]
    private void Start()
    {   
        if (m_ShadowCam == null) {
            enabled = false;
            return;
        }

        m_ShadowCam.clearFlags = CameraClearFlags.SolidColor;
        m_ShadowCam.backgroundColor = Color.clear;

        var mainCam = m_Proj.GetComponent<Camera>();
        m_Proj.nearClipPlane = mainCam.nearClipPlane;
        m_Proj.farClipPlane = mainCam.farClipPlane;
        m_Proj.fieldOfView = mainCam.fieldOfView;
        m_Proj.ignoreLayers = ~(1 << LayerMask.NameToLayer("Ground"));

        
        m_Proj.material = m_Mat;

        m_Mat.SetTexture("_ShadowTex", m_ShadowCam.targetTexture);
        m_Mat.SetFloat("_Strength", m_Strength);
    }

    private void OnEnable()
    {
        if (m_ShadowCam == null) return;
        m_ShadowCam.enabled = true;

        if (m_Mat == null) {
            m_Mat = new Material(Shader.Find("Projector/ShadowMap"));
        }
        if (m_ShadowCam.targetTexture == null) {
            RenderTexture tex = null;
            if (!string.IsNullOrEmpty(m_TexPath)) {
                var go = GoTools.Seek(m_TexPath);
                if (go) {
                    var com = go.GetComponent(this.GetType()) as ShadowProjector;
                    if (com) tex = com.m_Tex;
                }
            }

            if (tex == null) {
                if (m_Tex == null) GenTexture();
                tex = m_Tex;
            }

            m_ShadowCam.targetTexture = tex;

            m_Mat.SetTexture("_ShadowTex", tex);
            m_Mat.SetFloat("_Strength", m_Strength);
        }
    }

    private void OnDisable()
    {
        if (!string.IsNullOrEmpty(m_TexPath)) {
            m_ShadowCam.targetTexture = null;
        }
    }

    private void LateUpdate()
    {
        var matVP = GL.GetGPUProjectionMatrix(m_ShadowCam.projectionMatrix, true) * m_ShadowCam.worldToCameraMatrix;
        m_Mat.SetMatrix("ShadowMatrix", matVP);

        if (m_Auto) {
            CreateCameraProjecterMatrix();
        }
    }

    private void OnDestroy()
    {        
        Destroy(m_Tex);
        Destroy(m_Mat);
    }

    public void SetAuto(bool auto)
    {
        this.m_Auto = auto;
    }

    private static List<Transform> m_VisibleObjs = new List<Transform>();
    public static void SetVisible(Transform obj, bool visible)
    {
        if (visible) {
            if (!m_VisibleObjs.Contains(obj)) {
                m_VisibleObjs.Add(obj);
            }
        } else {
            m_VisibleObjs.Remove(obj);
        }
    }

    private void CreateCameraProjecterMatrix()
    {
        if (m_VisibleObjs.Count == 0) return;


        Vector3 v3MaxPosition = -Vector3.one * 500000.0f;
        Vector3 v3MinPosition = Vector3.one * 500000.0f;

        for (int vertId = 0; vertId < m_VisibleObjs.Count; ++vertId) {
            var v3Position = m_VisibleObjs[vertId].position;
            if (v3Position.x > v3MaxPosition.x) {
                v3MaxPosition.x = v3Position.x;
            }
            if (v3Position.y > v3MaxPosition.y) {
                v3MaxPosition.y = v3Position.y;
            }
            if (v3Position.z > v3MaxPosition.z) {
                v3MaxPosition.z = v3Position.z;
            }
            if (v3Position.x < v3MinPosition.x) {
                v3MinPosition.x = v3Position.x;
            }
            if (v3Position.y < v3MinPosition.y) {
                v3MinPosition.y = v3Position.y;
            }
            if (v3Position.z < v3MinPosition.z) {
                v3MinPosition.z = v3Position.z;
            }
        }
        var center = Vector3.Lerp(v3MinPosition, v3MaxPosition, 0.5f);
        var camPos = m_ShadowCam.transform.position;
        m_ShadowCam.transform.position = new Vector3(center.x, camPos.y, center.z);

        v3MaxPosition = -Vector3.one * 500000.0f;
        v3MinPosition = Vector3.one * 500000.0f;
        for (int vertId = 0; vertId < m_VisibleObjs.Count; ++vertId) {
            var objPos = m_VisibleObjs[vertId].position;
            Vector3 v3Position = m_ShadowCam.worldToCameraMatrix.MultiplyPoint3x4(objPos);
            if (v3Position.x > v3MaxPosition.x) {
                v3MaxPosition.x = v3Position.x;
            }
            if (v3Position.y > v3MaxPosition.y) {
                v3MaxPosition.y = v3Position.y;
            }
            if (v3Position.z > v3MaxPosition.z) {
                v3MaxPosition.z = v3Position.z;
            }
            if (v3Position.x < v3MinPosition.x) {
                v3MinPosition.x = v3Position.x;
            }
            if (v3Position.y < v3MinPosition.y) {
                v3MinPosition.y = v3Position.y;
            }
            if (v3Position.z < v3MinPosition.z) {
                v3MinPosition.z = v3Position.z;
            }
        }

        
        var off = (v3MaxPosition - v3MinPosition).SetZ(0);
        float dis = off.magnitude;
        m_ShadowCam.orthographicSize = Mathf.Clamp(dis * 0.7f, 5, 30);
        //m_ShadowCam.farClipPlane = off.z + 50;
    }
}
