using System.Collections;
using System.Collections.Generic;
using ASL.FogOfWar;
using UnityEngine;

public struct FOWMapPos
{
    public int x;
    public int y;

    public FOWMapPos(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public override string ToString()
    {
        return string.Format("[{0},{1}]", x, y);
    }
}

/// <summary>
/// 屏幕空间战争迷雾
/// </summary>
public class FogOfWarEffect : MonoBehaviour
{

    public enum FogMaskType
    {
        /// <summary>
        /// 精确计算的FOV
        /// </summary>
        AccurateFOV,
        /// <summary>
        /// 基础FOV
        /// </summary>
        BasicFOV,
        /// <summary>
        /// 简单圆形
        /// </summary>
        Circular,

        CustomFOV,
    }

    public static FogOfWarEffect Instance {
        get {
            if (instance == null)
                instance = FindObjectOfType<FogOfWarEffect>();
            return instance;
        }
    }

    private static FogOfWarEffect instance;

    [SerializeField]
    private FilterMode m_FogMaskFilter = FilterMode.Bilinear;

    /// <summary>
    /// 迷雾蒙版类型
    /// </summary>
    public FogMaskType fogMaskType { get { return m_FogMaskType; } }
    /// <summary>
    /// 战争迷雾颜色(RGB迷雾颜色，Alpha已探索区域透明度)
    /// </summary>
    public Color fogColor { get { return m_FogColor; } }
    /// <summary>
    /// 迷雾区域宽度
    /// </summary>
    public float xSize { get { return m_XSize; } }
    /// <summary>
    /// 迷雾区域高度
    /// </summary>
    public float zSize { get { return m_ZSize; } }
    /// <summary>
    /// 迷雾贴图宽度
    /// </summary>
    public int texWidth { get { return m_TexWidth; } }
    /// <summary>
    /// 迷雾贴图高度
    /// </summary>
    public int texHeight { get { return m_TexHeight; } }
    /// <summary>
    /// 迷雾区域中心坐标
    /// </summary>
    public Vector3 centerPosition { get { return m_CenterPosition; } }

    public float heightRange { get { return m_HeightRange; } }

    public int zoom { get; private set; }
    public int extend { get; private set; }

    public Texture2D fowMaskTexture {
        get {
            if (m_Map != null)
                return m_Map.GetFOWTexture();
            return null;
        }
    }

    [SerializeField]
    private FogMaskType m_FogMaskType;
    [SerializeField]
    private Color m_FogColor = Color.black;
    [SerializeField]
    private float m_MixInterval = 1f;

    [SerializeField]
    private float m_XSize;
    [SerializeField]
    private float m_ZSize;
    [SerializeField]
    private int m_TexWidth;
    [SerializeField]
    private int m_TexHeight;
    [SerializeField]
    private Vector3 m_CenterPosition;
    [SerializeField]
    private float m_HeightRange;
    /// <summary>
    /// 模糊偏移量
    /// </summary>
    [SerializeField]
    private float m_BlurOffset;
    /// <summary>
    /// 模糊迭代次数
    /// </summary>
    [SerializeField]
    private int m_BlurInteration;

    /// <summary>
    /// 迷雾特效shader
    /// </summary>
    public Shader effectShader;
    /// <summary>
    /// 模糊shader
    /// </summary>
    public Shader blurShader;

    /// <summary>
    /// 预生成的地图FOV数据（如果为空则使用实时计算FOV）
    /// </summary>
    //public FOWPregenerationFOVMapData pregenerationFOVMapData;

    /// <summary>
    /// 战争迷雾地图对象
    /// </summary>
    private FOWMap m_Map;
    public Texture2D fogTex { get { return m_Map.GetFOWTexture(); } }

    /// <summary>
    /// 战争迷雾渲染器
    /// </summary>
    private FOWRenderer m_Renderer;

    private MeshRenderer m_PlaneRenderer;

    private bool m_IsInitialized;

    private float m_MixTime = 0.0f;

    private float m_DeltaX;
    private float m_DeltaZ;
    private float m_InvDeltaX;
    private float m_InvDeltaZ;

    private Camera m_Camera;
    
    private Vector3 m_BeginPos;

    private bool m_FogDirty = true;
    private List<FOWFieldData> m_FieldDatas = new List<FOWFieldData>();
    
    void Awake()
    {
#if UNITY_EDITOR
        if (effectShader && !effectShader.isSupported)
            effectShader = Shader.Find(effectShader.name);

        if (blurShader && !blurShader.isSupported)
            blurShader = Shader.Find(blurShader.name);
#endif

        m_IsInitialized = Init();
        enabled = m_IsInitialized;

    }

    void OnDestroy()
    {
        if (m_Renderer != null)
            m_Renderer.Release();
        if (m_Map != null)
            m_Map.Release();
        if (m_FieldDatas != null)
            m_FieldDatas.Clear();
        m_FieldDatas = null;
        m_Renderer = null;
        m_Map = null;
        instance = null;
    }

    void LateUpdate()
    {
        /*
        更新迷雾纹理
        */
        if (m_MixTime < m_MixInterval) {
            m_Renderer.SetFogFade(m_MixTime / m_MixInterval);
            m_MixTime += Time.deltaTime;
        } else {
            if (m_Map.RefreshFOWTexture()) {
                m_MixTime = 0;
                m_Renderer.SetFogFade(0);
            } else {
                m_Renderer.SetFogFade(1);
                if (m_FogDirty && m_Map.maskTexture.IsIdle()) {
                    m_FogDirty = false;
                    m_Map.SetVisible(m_FieldDatas);
                }
            }
        }
        
        m_Renderer.RenderFogOfWar(m_Camera, m_Map.GetFOWTexture());
    }

    void OnEnable()
    {
        if (m_PlaneRenderer != null)
            m_PlaneRenderer.enabled = true;
    }
    
    void OnDisable()
    {
        if (m_PlaneRenderer != null)
            m_PlaneRenderer.enabled = false;
    }
    
    Mesh CreateMesh(float width, float height)
    {
        // 跟主角高度差不多一致
        var y = 1.5f;
        Mesh m = new Mesh();
        m.name = "FogOfWarMesh";
        m.vertices = new Vector3[] {
            new Vector3(-width/2, y, -height/2),
            new Vector3(width/2, y, -height/2),
            new Vector3(width/2, y, height/2),
            new Vector3(-width/2, y, height/2),
            
            new Vector3(-width, y, -height),
            new Vector3(width, y, -height),
            new Vector3(width, y, height),
            new Vector3(-width, y, height)
        };
        m.uv = new Vector2[] {
            new Vector2 (1, 1),
            new Vector2 (0, 1),
            new Vector2(0, 0),
            new Vector2 (1, 0),
            
            new Vector2 (2, 2),
            new Vector2 (-1, 2),
            new Vector2(-1, -1),
            new Vector2 (2, -1)
        };
        m.triangles = new int[]
        {
            0, 2, 1,
            0, 3, 2,
            0, 1, 5,
            0, 5, 4,
            1, 6, 5,
            1, 2, 6,
            2, 7, 6,
            2, 3, 7,
            3, 4, 7,
            3, 0, 4
        };
        m.RecalculateNormals();
         
        return m;
    }

    private bool Init()
    {
        if (m_XSize <= 0 || m_ZSize <= 0 || m_TexWidth <= 0 || m_TexHeight <= 0)
            return false;
        if (effectShader == null || !effectShader.isSupported)
            return false;
        m_Camera = gameObject.GetComponent<Camera>();
        if (m_Camera == null)
            return false;
        //m_Camera.depthTextureMode |= DepthTextureMode.Depth;
        m_DeltaX = m_XSize / m_TexWidth;
        m_DeltaZ = m_ZSize / m_TexHeight;
        m_InvDeltaX = 1.0f / m_DeltaX;
        m_InvDeltaZ = 1.0f / m_DeltaZ;
        m_BeginPos = m_CenterPosition - new Vector3(m_XSize * 0.5f, 0, m_ZSize * 0.5f);
        m_Map = new FOWMap(m_BeginPos, m_XSize, m_ZSize, m_TexWidth, m_TexHeight, m_HeightRange) {
            fogMask = m_FogMaskType
        };
        IFOWMapData md = gameObject.GetComponent<IFOWMapData>();
        if (md != null)
            m_Map.SetMapData(md);
        else {
            m_Map.SetMapData(new FOWMapData(m_TexHeight, m_TexHeight));
            m_Map.GenerateMapData(m_HeightRange);
        }
        
        // // 造一个摄像机，挂在主摄像机上，用于渲染迷雾，摄像机参数与主摄像机一样，不用clear，深度比主摄像机高，用于遮挡住场景里的所有内容
        // var fowCameraGo = new GameObject("Fog of war Camera");
        // fowCameraGo.transform.parent = transform;
        // fowCameraGo.transform.localPosition = Vector3.zero;
        // fowCameraGo.transform.localScale = Vector3.one;
        // fowCameraGo.transform.localRotation = Quaternion.identity;
        //
        // var fowCamera = fowCameraGo.AddComponent<Camera>();
        // fowCamera.clearFlags = CameraClearFlags.Nothing;
        // fowCamera.projectionMatrix = m_Camera.projectionMatrix;
        // fowCamera.fieldOfView = m_Camera.fieldOfView;
        // fowCamera.depth = m_Camera.depth + 1;
        // fowCamera.targetTexture = m_Camera.targetTexture;
        // fowCamera.cullingMask = LayerMask.GetMask("Cloud");
        // fowCamera.allowMSAA = m_Camera.allowMSAA;
        // fowCamera.allowHDR = m_Camera.allowHDR;
        // fowCamera.allowDynamicResolution = m_Camera.allowDynamicResolution;
        
        // 再在场景里造一个片，用于渲染迷雾，因为是用上面的摄像机渲染，Alpha Blend以后，就有了迷雾效果
        var plane = new GameObject("Fog of war Plane");
        plane.transform.localPosition = m_CenterPosition;
        plane.transform.localScale = new Vector3(m_XSize, 1, m_ZSize);
        plane.transform.localRotation = Quaternion.Euler(0, 180, 0);
        MeshFilter meshFilter = (MeshFilter)plane.AddComponent(typeof(MeshFilter));
        meshFilter.mesh = CreateMesh(1, 1f);
        m_PlaneRenderer = (MeshRenderer)plane.AddComponent(typeof(MeshRenderer));
        m_PlaneRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        m_PlaneRenderer.receiveShadows = false;
        plane.layer = LayerMask.NameToLayer("Cloud");

        gameObject.GetComponent<Camera>().cullingMask |= (1 << plane.layer);

        var mat = new Material(effectShader);
        m_PlaneRenderer.material = mat;
        
        m_Renderer = new FOWRenderer(mat, blurShader, m_CenterPosition, m_XSize, m_ZSize, m_FogColor, m_BlurOffset, m_BlurInteration);
        
        
        return true;
    }

    public void ReInit(Vector2 size, Vector3 center, int zoom, int extend)
    {
        this.zoom = zoom;
        this.extend = extend;

        m_XSize = size.x + extend * 2;
        m_ZSize = size.y + extend * 2;
        m_TexWidth = (int)m_XSize;
        m_TexHeight = (int)m_ZSize;
        m_CenterPosition = center;

        m_IsInitialized = Init();
        enabled = m_IsInitialized;
    }

    public void RegFogUpdated(System.Action<Texture, Material> onUpdated)
    {
        m_Renderer.onFogTexUpdated += onUpdated;
    }

    public void UnregFogUpdated(System.Action<Texture, Material> onUpdated)
    {
        m_Renderer.onFogTexUpdated -= onUpdated;
    }

    public static void SetDirty()
    {
        Instance.m_MixTime = Instance.m_MixInterval;
    }

    /// <summary>
    /// 标志视野数据过时，需要重新计算
    /// </summary>
    public static void SetFieldDataDirty()
    {
        Instance.m_FogDirty = true;
    }

    public static bool IsEffecting()
    {
        return Instance && Instance.enabled && Instance.m_IsInitialized;
    }

    /// <summary>
    /// 世界坐标转战争迷雾坐标
    /// </summary>
    /// <param name="position"></param>
    /// <returns></returns>
    public static FOWMapPos WorldPositionToFOW(Vector3 position)
    {
        if (!Instance)
            return default(FOWMapPos);
        if (!Instance.m_IsInitialized)
            return default(FOWMapPos);

        int x = Mathf.FloorToInt((position.x - Instance.m_BeginPos.x) * Instance.m_InvDeltaX);
        int z = Mathf.FloorToInt((position.z - Instance.m_BeginPos.z) * Instance.m_InvDeltaZ);

        return new FOWMapPos(x, z);
    }
    
    public static void UpdateFOWFieldData(FOWFieldData data)
    {
        if (IsEffecting()) {
            if (!Instance.m_FieldDatas.Contains(data)) {
                Instance.m_FieldDatas.Add(data);
            }
            Instance.m_FogDirty = true;
        }
    }

    public static void ReleaseFOWFieldData(FOWFieldData data)
    {
        if (!instance)
            return;
        if (!instance.m_IsInitialized)
            return;
        //lock (instance.m_FieldDatas)
        {
            if (instance.m_FieldDatas.Contains(data))
                instance.m_FieldDatas.Remove(data);
            Instance.m_FogDirty = true;
        }
    }

    /// <summary>
    /// 是否在地图中可见
    /// </summary>
    /// <param name="position"></param>
    /// <returns></returns>
    public static bool IsVisibleInMap(Vector3 position)
    {
        if (IsEffecting()) {
            int x = Mathf.FloorToInt((position.x - Instance.m_BeginPos.x) * Instance.m_InvDeltaX);
            int z = Mathf.FloorToInt((position.z - Instance.m_BeginPos.z) * Instance.m_InvDeltaZ);

            return Instance.m_Map.IsVisibleInMap(x * Instance.zoom, z * Instance.zoom);
        }
        return true;
    }

      // 不需要后期处理了，这样效率比较低
//    void OnRenderImage(RenderTexture src, RenderTexture dst)
//    {
//        if (!m_IsInitialized)
//            Graphics.Blit(src, dst);
//        else {
//            m_Renderer.RenderFogOfWar(m_Camera, m_Map.GetFOWTexture(), src, dst);
//        }
//    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (m_Map != null) {
            m_Map.fogMask = m_FogMaskType;

            var maskTex = m_Map.GetFOWTexture();
            if (maskTex && maskTex.filterMode != m_FogMaskFilter) {
                maskTex.filterMode = m_FogMaskFilter;
            }
        }

        if(m_Renderer != null) {
            m_Renderer.UpdateBlurParams(m_FogColor, m_BlurOffset, m_BlurInteration);
        }
    }

    void OnDrawGizmosSelected()
    {
        FOWUtils.DrawFogOfWarGizmos(m_CenterPosition, m_XSize, m_ZSize, m_TexWidth, m_TexHeight, m_HeightRange);
    }
#endif
}
