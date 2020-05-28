using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class FxMotionTrail : FX.FxTiming
{	
	class XTrailSection
	{
		public static XTrailSection Catmull_Rom(XTrailSection p0, XTrailSection p1,
		                                        XTrailSection p2, XTrailSection p3,
		                                        float t)
		{
			XTrailSection section = new XTrailSection();
			
			float t2 = t * t;
			float t3 = t2 * t;
			float a0 = -t3 + 2 * t2 - t;
			float a1 = 3 * t3 - 5 * t2 + 2;
			float a2 = -3 * t3 + 4 * t2 + t;
			float a3 = t3 - t2;
			
			section.pointS = (a0 * p0.pointS + a1 * p1.pointS + a2 * p2.pointS + a3 * p3.pointS) * 0.5f;
			section.pointE = (a0 * p0.pointE + a1 * p1.pointE + a2 * p2.pointE + a3 * p3.pointE) * 0.5f;
			section.time = (a0 * p0.time + a1 * p1.time + a2 * p2.time + a3 * p3.time) * 0.5f;
			
			return section;
		}
		
		public Vector3 pointS;
		public Vector3 pointE;
		public float time;
	}
	
	class XTrailMesh
	{
		public Vector3[] vertices = null;
		public Color[] colors = null;
		public Vector2[] uv = null;
		public int[] triangles = null;
	}

    public bool m_followTarget = true;
    public float m_time = 2.0f;
    public float m_minDistance = 0.1f;
    public Color m_startColor = Color.white;
    public Color m_endColor = new Color(1, 1, 1, 0);
    public int m_MaxSections = 10;
    public int m_MaxSegments = 3;
    public Material m_material = null;
    public float m_startWidth = 1;
    public float m_endWidth = 1;

    Vector3 m_refStartPoint = Vector3.left;
    Vector3 m_refEndPoint = Vector3.right;
    float m_trailScale = 1.0f;    

    private List<XTrailSection> _m_sections = new List<XTrailSection>();
    private List<XTrailSection> _m_sectionsT = new List<XTrailSection>();
    private Mesh _m_mesh = null;
    private GameObject _m_GO = null;
    private Transform _m_GO_trans = null;
    private Transform _m_Cam_trans = null;
    Vector3 lastTrailPosition = Vector3.zero;

    float Now { get { return ignoreTimeScale ? Time.unscaledTime : Time.time; } }

    protected override void Awake()
    {
        base.Awake();

        _m_GO = new GameObject("Trail");
        _m_GO_trans = _m_GO.transform;
        _m_GO_trans.parent = this.transform;
        _m_GO_trans.localPosition = Vector3.zero;
        _m_GO_trans.localRotation = Quaternion.identity;
        _m_mesh = _m_GO.AddComponent<MeshFilter>().mesh;
        _m_GO.AddComponent<MeshRenderer>();
        if (m_material != null) {
            UpdateMat(m_material);
        }
    }
    
    protected void Start()
    {
        _m_Cam_trans = Camera.main.transform;
        SyncStatus();
    }

    protected void LateUpdate()
    {
        SyncStatus();

        Matrix4x4 mat = _m_GO_trans.localToWorldMatrix;
        Vector3 S = mat.MultiplyPoint(m_refStartPoint);
        Vector3 E = mat.MultiplyPoint(m_refEndPoint);
        float now = Now;

        //Add a new trail section:
        float sqrDistance = m_minDistance * m_minDistance;
        if (_m_sections.Count == 0 ||
            (_m_sections[0].pointS - S).sqrMagnitude > sqrDistance ||
            (_m_sections[0].pointE - E).sqrMagnitude > sqrDistance) {
            XTrailSection section = new XTrailSection();
            section.pointS = S;
            section.pointE = E;
            section.time = now;
            _m_sections.Insert(0, section);
        }

        //Remove old sections:
        while (_m_sections.Count > 0 &&
        (now > _m_sections[_m_sections.Count - 1].time + m_time ||
        _m_sections.Count > m_MaxSections)) {
            _m_sections.RemoveAt(_m_sections.Count - 1);
        }

        //Rebuild mesh:
        _m_mesh.Clear();

        if (_m_sections.Count < 4)
            return;

        //Generate mesh:
        XTrailMesh trailMesh = GenerateTrailMesh();

        //Assign to mesh:
        if (trailMesh != null) {
            _m_mesh.vertices = trailMesh.vertices;
            _m_mesh.colors = trailMesh.colors;
            _m_mesh.uv = trailMesh.uv;
            _m_mesh.triangles = trailMesh.triangles;
        }
    }
    
    protected void OnDrawGizmosSelected()
    {
        Matrix4x4 mat = transform.localToWorldMatrix;
        //mat.m00 = mat.m11 = mat.m22 = mat.m33 = 1.0f;
        mat.MultiplyPoint(m_refStartPoint);

        Vector3 S = mat.MultiplyPoint(m_refStartPoint);
        Vector3 E = mat.MultiplyPoint(m_refEndPoint);

        Gizmos.DrawWireSphere(S, 0.02f);
        Gizmos.DrawWireSphere(E, 0.02f);
        Gizmos.DrawLine(S, E);
    }

    private void SyncStatus()
    {
        if (!m_followTarget) {
            Vector3 trailDirt = _m_GO_trans.position - lastTrailPosition;
            if (trailDirt != Vector3.zero) {
                Vector3 camDirt = _m_GO_trans.position - _m_Cam_trans.position;
                Vector3 dirt = Vector3.Cross(trailDirt, camDirt);
                _m_GO_trans.LookAt(_m_GO_trans.position + dirt);
            }
        }

        lastTrailPosition = _m_GO_trans.position;
        m_refStartPoint = new Vector3(0, 0, -m_startWidth / 2);
        m_refEndPoint = new Vector3(0, 0, m_startWidth / 2);
        m_trailScale = 1 - m_endWidth / m_startWidth;
    }

    private XTrailMesh GenerateTrailMesh()
    {
        List<XTrailSection> sections = InterpolateTrailMesh();

        XTrailMesh trailMesh = new XTrailMesh();
        trailMesh.vertices = new Vector3[sections.Count * 2];
        trailMesh.colors = new Color[sections.Count * 2];
        trailMesh.uv = new Vector2[sections.Count * 2];

        XTrailSection curSection = sections[0];

        //Use matrix instead of transform.TransformPoint for performance reasons
        Matrix4x4 localSpaceTransform = _m_GO_trans.worldToLocalMatrix;

        //Generate vertex, uv and colors:
        Vector2 uv1 = Vector2.zero;
        Vector2 uv2 = Vector2.zero;

        for (int i = 0; i < sections.Count; i++) {
            curSection = sections[i];

            //Calculate u for texture uv and color interpolation:
            float u = 0.0f;
            if (i != 0)
                u = Mathf.Clamp01((Now - curSection.time) / m_time);

            //Generate vertices:
            float scale = (1.0f / (float)(sections.Count - 1)) * i * 0.5f * m_trailScale;
            Vector3 dirToS = curSection.pointS - curSection.pointE;
            float l = dirToS.magnitude;
            dirToS.Normalize();

            curSection.pointS += (l * scale * -dirToS);
            curSection.pointE += (l * scale * dirToS);
            trailMesh.vertices[i * 2 + 0] = localSpaceTransform.MultiplyPoint(curSection.pointS);
            trailMesh.vertices[i * 2 + 1] = localSpaceTransform.MultiplyPoint(curSection.pointE);

            uv1.x = u; uv1.y = 0;
            uv2.x = u; uv2.y = 1;
            trailMesh.uv[i * 2 + 0] = uv1;
            trailMesh.uv[i * 2 + 1] = uv2;

            //fade colors out over time:
            Color interpolatedColor = Color.Lerp(m_startColor, m_endColor, u);
            trailMesh.colors[i * 2 + 0] = interpolatedColor;
            trailMesh.colors[i * 2 + 1] = interpolatedColor;
        }

        //Generate triangles indices:
        trailMesh.triangles = new int[(sections.Count - 1) * 2 * 3];
        for (int i = 0; i < trailMesh.triangles.Length / 6; i++) {
            trailMesh.triangles[i * 6 + 0] = i * 2;
            trailMesh.triangles[i * 6 + 1] = i * 2 + 1;
            trailMesh.triangles[i * 6 + 2] = i * 2 + 2;

            trailMesh.triangles[i * 6 + 3] = i * 2 + 2;
            trailMesh.triangles[i * 6 + 4] = i * 2 + 1;
            trailMesh.triangles[i * 6 + 5] = i * 2 + 3;
        }
        return trailMesh;
    }

    private List<XTrailSection> InterpolateTrailMesh()
    {
        if (m_MaxSegments <= 0) m_MaxSegments = 1; int total = (_m_sections.Count - 1) * m_MaxSegments; while (_m_sectionsT.Count > total)
            _m_sectionsT.RemoveAt(0);

        for (int i = 0; i < _m_sections.Count - 1; i++) {
            XTrailSection p0, p1, p2, p3; if (i == 0) p0 = _m_sections[i]; else p0 = _m_sections[i - 1]; p1 = _m_sections[i]; p2 = _m_sections[i + 1]; if (i + 2 >= _m_sections.Count - 1)
                p3 = _m_sections[i + 1];
            else
                p3 = _m_sections[i + 2];

            for (int delta = 0; delta < m_MaxSegments; delta++) {
                float t = (float)delta / (float)m_MaxSegments;
                int index = (i * m_MaxSegments) + delta;
                if (index < _m_sectionsT.Count)
                    _m_sectionsT[index] = XTrailSection.Catmull_Rom(p0, p1, p2, p3, t);
                else
                    _m_sectionsT.Add(XTrailSection.Catmull_Rom(p0, p1, p2, p3, t));
            }
        }
        return _m_sectionsT;
    }

    public void UpdateMat(Material mat)
    {
        m_material = mat;
        _m_GO.GetComponent<MeshRenderer>().sharedMaterial = m_material;
    }

    public void ClearTrail()
    {
        _m_mesh.Clear();
    }
}
