using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dest.Math;
using ZFrame.Asset;
using TinyJSON;
using UnityEngine.AI;

namespace World.View
{
    public class ReedEdit : ConvexPolygonBuildTag, IObjView
    {
        public enum Type
        {
            None, Grass,
        }

        [SerializeField, AssetRef(type: typeof(GameObject))]
        private string m_AssetPath;

        [SerializeField]
        private int m_GroupId;
        public int group { get { return m_GroupId; } }

        [SerializeField]
        private Type m_Type = Type.Grass;
        public Type type { get { return m_Type; } }
        
        [SerializeField]
        private Color m_Color = Color.green;
        public Color color { get { return m_Color; } }
        
        private ReedObj m_Obj;
        public IObj obj { get { return m_Obj; } }

        private Polygon2 m_Polygon;

        private bool m_HasLoaded;

        public Polygon2 ToPolygon(Vector3 offset)
        {
            var origin = transform.localPosition + offset;
            var polygon = new Polygon2(points.Length);
            for (int i = 0; i < points.Length; ++i) {
                var p = origin + points[i];
                polygon.Vertices[i] = new Vector2(p.x, p.z);
            }
            return polygon;
        }

        [ContextMenu("导出数据")]
        public Variant ToJsonObj()
        {
            var stageEdit = GetComponentInParent(typeof(StageEdit)) as StageEdit;
            if (stageEdit == null || stageEdit.start == null) {
                Debug.LogWarning("场景未配置完成，忽略芦苇丛导出。");
                return null;
            }

            var polygon = ToPolygon(Vector3.zero);
            float xMin, xMax, yMin, yMax;
            polygon.GetBound(out xMin, out xMax, out yMin, out yMax);

            var joReed = new ProxyObject();
            joReed.Add("group", new ProxyNumber(m_GroupId));
            joReed.Add("type", new ProxyNumber((int)m_Type));

            var joArray = new ProxyArray();

            Vector2 start = Vector2.zero, size = Vector2.zero;
            Vector2 next = Vector2.zero;
            int clipping = 0;
            for (int i = Mathf.RoundToInt(xMin); i < xMax; ++i) {
                int s = 0, h = 0;
                for (int j = Mathf.RoundToInt(yMin); j < yMax; ++j) {
                    if (i >= 0 && j >= 0 && i < stageEdit.size.x && j < stageEdit.size.y) {
                        if (polygon.ContainsConvexCCW(new Vector2(i, j))) {
                            if (clipping == 0) {
                                clipping = 1;
                                start.x = i; start.y = j;
                                size.x = 1; size.y = 1;
                                s = j; h = 1;
                            } else {
                                h += 1;
                                if (clipping == 2) {
                                    clipping = 3;
                                    s = j;
                                    next.x = i; next.y = j;
                                }
                            }
                        }
                    }
                }

                if (clipping > 0) {
                    if (clipping > 1) {
                        if (s != (int)start.y || h != (int)size.y) {
                            var box = new StageEdit.Box() {
                                start = start, size = size,
                            };
                            joArray.Add(box.ToJsonObj());

                            clipping = 1;
                            start.x = next.x; start.y = next.y;
                            size.x = 1;
                        } else {
                            size.x += 1;
                        }
                    }
                    clipping = 2;
                    size.y = h;
                }
            }

            if (size.y > 0) {
                var box = new StageEdit.Box() {
                    start = start, size = size,
                };
                joArray.Add(box.ToJsonObj());
            }
            joReed.Add("Boxes", joArray);

            return joReed;
        }

        public bool IsNull() { return this == null; }

        public bool IsVisible()
        {
            return !IsNull();
        }

        public void LoadView()
        {
            if (transform.childCount == 0) {
                var stageEdit = GetComponentInParent(typeof(StageEdit)) as StageEdit;
                if (stageEdit && stageEdit.start) {
                    if (!m_HasLoaded) {
                        AssetsMgr.A.LoadAsync(
                            typeof(GameObject), m_AssetPath, LoadMethod.Cache, OnAssetLoaded, stageEdit);
                    }
                    else {
                        string bundleName, assetName;
                        AssetLoader.GetAssetpath(m_AssetPath, out bundleName, out assetName);
                        foreach (Transform t in transform) {
                            if (t.name == assetName) t.gameObject.SetActive(true);
                        }
                    }
                }

                var filter = GenerateMesh();

                var source = new NavMeshBuildSource
                {
                    shape = NavMeshBuildSourceShape.Mesh,
                    area = m_Area,
                    sourceObject = filter.sharedMesh,
                    transform = filter.transform.localToWorldMatrix,
                };

                if (StageView.Instance.IsNewNavMeshBuild(this)) {
                    StageView.Instance.AddNavMeshBuild(this, source);
                }
            }
            else {
                foreach (Transform child in transform)
                {
                    child.gameObject.SetActive(true);
                }
            }
        }

        private IEnumerator RemoveReed()
        {
            var center = StageView.Local2World(m_Obj.coord);
            var waitBurn = new WaitForSeconds(1f);
            var waitSpread = new WaitForSeconds(0.2f);
            var radius = 0f;
            yield return AssetsMgr.A.Loader.LoadingAsset(typeof(GameObject), "fx/burn/burn_reed_dead", LoadMethod.Cache);
            var fxPrefab = AssetsMgr.A.Loader.loadedObj as GameObject;

            var list = ZFrame.ListPool<Component>.Get();
            for (int n = transform.childCount; n > 0;) {
                radius += 1f;
                for (int i = transform.childCount - 1; i >= 0; --i) {
                    var child = transform.GetChild(i);
                    if (child && child.gameObject.activeSelf && Vector3.Distance(child.position, center) < radius) {
                        list.Add(child);
                        if (fxPrefab) {
                            var go = GoTools.AddChild(child.gameObject, fxPrefab, true);
                            go.Attach(FX.FxTool.FxRoot, true);
                        }
                    }
                }
                yield return waitBurn;

                n -= list.Count;
                foreach (var child in list) {
                    child.gameObject.SetActive(false);
                }
                list.Clear();
                yield return waitSpread;
            }
        }

        public void UnloadView()
        {
            StartCoroutine(RemoveReed());
    
            StageView.Instance.RemoveNavMeshBuild(this);
        }

        public void HandlerGrids(StageEdit edit, System.Action<ReedEdit, int, int> handler)
        {
            var polygon = ToPolygon(new Vector3(-0.5f, 0, -0.5f));
            float xMin, xMax, yMin, yMax;
            polygon.GetBound(out xMin, out xMax, out yMin, out yMax);

            for (int i = Mathf.RoundToInt(xMin); i < xMax; ++i) {
                for (int j = Mathf.RoundToInt(yMin); j < yMax; ++j) {
                    if (i >= 0 && j >= 0 && i < edit.size.x && j < edit.size.y) {
                        if (polygon.ContainsConvexCCW(new Vector2(i, j))) {
                            handler.Invoke(this, i, j);
                        }
                    }
                }
            }
        }

        private void OnAssetLoaded(string a, object o, object param)
        {
            var prefab = o as GameObject;
            if (prefab) {
                var stageEdit = param as StageEdit;
                var origin = transform.localPosition;
                HandlerGrids(stageEdit, (reed, i, j) => {
                    var go = GoTools.NewChild(gameObject, prefab);
                    var center = new Vector3(i - origin.x + 0.5f, 0, j - origin.z + 0.5f);
                    var off = Random.insideUnitCircle / 4;
                    go.transform.localPosition = center + new Vector3(off.x, 0, off.y);
                    go.transform.localEulerAngles = new Vector3(0, Random.Range(0, 360), 0);
                });
                StaticBatchingUtility.Combine(gameObject);
            }
            m_HasLoaded = true;
        }

        public void Subscribe(IObj o)
        {
            m_Obj = o as ReedObj;
        }

        public void Unsubscribe()
        {
            m_Obj = null;
        }

        public void Destruct(float delay)
        {
            Destroy(gameObject, delay);
        }

        protected override void Start()
        {
            // 忽略自动创建NavMeshBuildTag
        }

        private void OnDestroy()
        {
            var filter = gameObject.GetComponent(typeof(MeshFilter)) as MeshFilter;
            if (filter && filter.sharedMesh) {
                Object.Destroy(filter.sharedMesh);
            }
        }

#if UNITY_EDITOR
        public void DrawGizmos()
        {
            var stageEdit = GetComponentInParent(typeof(StageEdit)) as StageEdit;
            if (stageEdit && stageEdit.start) {
                var defColor = Gizmos.color;
                var defMatrix = Gizmos.matrix;
                Gizmos.matrix = stageEdit.start.localToWorldMatrix;
                Gizmos.color = m_Color;

                HandlerGrids(stageEdit, (reed, i, j) => {
                    var boxSize = new Vector3(0.9f, 0f, 0.9f);
                    Gizmos.DrawCube(new Vector3(i + 0.5f, 0, j + 0.5f), boxSize);
                });

                Gizmos.color = defColor;
                Gizmos.matrix = defMatrix;
            }
        }

        protected override void OnDrawGizmosSelected()
        {
            var stageEdit = GetComponentInParent(typeof(StageEdit)) as StageEdit;
            if (stageEdit && stageEdit.start) {
                if (UnityEditor.Selection.activeGameObject == gameObject) {
                    stageEdit.DrawGizmosSelected();
                }
            }
        }
#endif

    }
}
