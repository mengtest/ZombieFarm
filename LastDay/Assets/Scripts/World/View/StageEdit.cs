using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using TinyJSON;

namespace World.View
{
    public class StageEdit : MonoBehaviour
    {
#if UNITY_EDITOR
        private static StageEdit m_Shared;
        public static StageEdit Shared {
            get {
                if (!Application.isPlaying) {
                    var objs = FindObjectsOfType(typeof(StageEdit));
                    foreach (StageEdit o in objs) {
                        if (o.start && o.templateId == 0) {
                            return o;
                        }
                    }
                    return null;
                }
                return m_Shared;
            }
            set { m_Shared = value; }
        }
#else
        public static StageEdit Shared { get; private set; }
#endif

        public static Variant Vector2Json(Vector2 v2)
        {
            return new ProxyObject {
                { "x", new ProxyNumber(v2.x * CVar.LENGTH_MUL) },
                { "y", new ProxyNumber(v2.y * CVar.LENGTH_MUL) },
            };
        }

        public enum BlockLevel
        {
            Obstacle = -1, Block, Melee, Range1, Range2, Range3, Range4, Range5, 
            SIGHT = CVar.FULL_BLOCK - 1, MAX = CVar.FULL_BLOCK,
        }

        public enum PathMode
        {
            Loopback, Inverse,
        }

        [System.Serializable]
        public struct Box
        {
            public Vector2 start;
            public Vector2 size;
            public BlockLevel blockLevel;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "start", Vector2Json(start) },
                    { "size", Vector2Json(size) },
                };
            }
        }

        [System.Serializable]
        public struct Npc
        {
            public Vector2 coord;
            public int angle;
            public int id;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "start", Vector2Json(coord) },
                    { "angle", new ProxyNumber(angle) },
                    { "id", new ProxyNumber(id) },
                };
            }
        }
        
        [System.Serializable]
        public struct Area
        {
            public Vector2 coord;
            public Vector2 param;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "coord", Vector2Json(coord) },
                    { "param", Vector2Json(param) },
                };
            }
        }

        [System.Serializable]
        public struct Entrance
        {
            public Vector2 coord;
            public Vector2 param;
            public int angle;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "coord", Vector2Json(coord) },
                    { "param", Vector2Json(param) },
                    { "angle", new ProxyNumber(angle) },
                };
            }

            public static implicit operator Area(Entrance ent)
            {
                return new Area { coord = ent.coord, param = ent.param };
            }
        }

        [System.Serializable]
        public struct Wall
        {
            public Vector2 start, end;
            public BlockLevel blockLevel;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "start", Vector2Json(start) },
                    { "end", Vector2Json(end) },
                };
            }
        }

        [System.Serializable]
        public struct Spwaner
        {
            public Area source, destina;
            public int id, nInit, nMin;

            public Variant ToJsonObj()
            {
                return new ProxyObject() {
                    { "source", source.ToJsonObj() },
                    { "destina", destina.ToJsonObj() },
                    { "id", new ProxyNumber(id) },
                    { "nInit", new ProxyNumber(nInit) },
                    { "nMin", new ProxyNumber(nMin) },
                };
            }
        }

        [System.Serializable]
        public struct PatrolPath
        {
            public int id;
            public PathMode mode;
            public List<Vector2> points;

            public Variant ToJsonObj()
            {
                var array = new ProxyArray();
                foreach (var p in points) array.Add(Vector2Json(p));
                return new ProxyObject() {
                    { "id", new ProxyNumber(id) },
                    { "mode", new ProxyNumber((int)mode) },
                    { "points", array },
                };
            }
        }

        [SerializeField, Skip]
        private Material m_EdgeMat;

        [SerializeField, Skip]
        private Transform m_Start;

        [SerializeField, Skip]
        private int m_TemplateId;

        [SerializeField, Skip]
        private Vector2 m_Size = new Vector2(10, 10);
        
        [SerializeField, AssetRef(type:typeof(Texture)), Skip]
        private string m_MiniMap;
        public Texture mapTex { get; private set; }

        //障碍物
        [SerializeField, HideInInspector]
        private List<Box> m_Blocks = new List<Box>();

        //空气墙
        [SerializeField, HideInInspector]
        private List<Wall> m_Walls = new List<Wall>();

        //怪物
        [SerializeField, HideInInspector]
        private List<Npc> m_Npcs = new List<Npc>();

        //入口
        [SerializeField, HideInInspector]
        private List<Entrance> m_Ents = new List<Entrance>();

        //刷怪点
        [SerializeField, HideInInspector]
        private List<Spwaner> m_Spawners = new List<Spwaner>();

        //巡逻路
        [SerializeField, HideInInspector]
        private List<PatrolPath> m_PatrolPaths = new List<PatrolPath>();

        //出口
        [SerializeField, HideInInspector]
        private List<Area> m_Exits = new List<Area>();
        private Shape2D[] m_ExitAreaShapeArr = null;

        private List<ReedEdit> m_Reedbeds = new List<ReedEdit>();

        public Transform start { get { return m_Start; } }
        public int templateId { get { return m_TemplateId; } }
        public Vector2 size { get { return m_Size; } }
        public List<Box> blocks { get { return m_Blocks; } }
        public List<Wall> walls { get { return m_Walls; } }
        public List<Npc> npcs { get { return m_Npcs; } }
        public List<Entrance> ents { get { return m_Ents; } }
        public List<Spwaner> spawners { get { return m_Spawners; } }
        public List<PatrolPath> patrolPaths { get { return m_PatrolPaths; } }
        public List<ReedEdit> reedbeds { get { return m_Reedbeds; } }
        public List<Area> exits { get { return m_Exits; } }
        
        public Shape2D[] ExitAreaShape { get {
                if (m_ExitAreaShapeArr == null) {
                    InitExitArea();
                }
                return m_ExitAreaShapeArr;
            }
        }

        public bool inited { get; private set; }

        private void Awake()
        {
            if (templateId == 0) Shared = this;
        }

        private void OnDestroy()
        {
            var filter = gameObject.GetComponent(typeof(MeshFilter)) as MeshFilter;
            if (filter) {
                Destroy(filter.sharedMesh);
            }
            
            if (this == Shared) Shared = null;
        }

        private void InitExitArea()
        {
            m_ExitAreaShapeArr = new Shape2D[exits.Count];

            for (int i = 0; i < exits.Count; i++) {
                Area exitAreaInfo = exits[i];
                Shape2D exitShape;
                if (exitAreaInfo.param.y < 0 || Math.IsEqual(exitAreaInfo.param.y, 0f)) {
                    exitShape = new Shape2D(exitAreaInfo.coord, exitAreaInfo.param.x);
                } else {
                    exitShape = new Shape2D(exitAreaInfo.coord, Vector.forward, exitAreaInfo.param);
                }
                m_ExitAreaShapeArr[i] = exitShape;
            }
        }

        public IEnumerator<Box> ForEachBlock()
        {
            foreach (var block in blocks) {
                yield return block;
            }

            if (Shared != null && Shared != this) {
                var offset3d = Shared.m_Start.position - m_Start.position;
                var offset = new Vector2(offset3d.x, offset3d.z).Round();
                foreach (var block in Shared.blocks) {
                    var shBlock = block;
                    shBlock.start += offset;
                    yield return shBlock;
                }
            }
        }

        public IEnumerator<Wall> ForEachWall()
        {
            foreach (var wall in walls) {
                yield return wall;
            }

            if (Shared != null && Shared != this) {
                var offset3d = Shared.m_Start.position - m_Start.position;
                var offset = new Vector2(offset3d.x, offset3d.z).Round();
                foreach (var wall in Shared.walls) {
                    var shWall = wall;
                    shWall.start += offset;
                    shWall.end += offset;
                    yield return shWall;
                }
            }
        }

        public void Init(Stage L)
        {
            inited = false;

            var forward = new Vector(0, 0, 1);
            var fixedV2 = new Vector2(0.5f, 0.5f);

            using (var itor = ForEachBlock()) {
                while (itor.MoveNext()) {
                    var block = itor.Current;
                    var point = block.start + block.size / 2;
                    var blockLevel = (int)block.blockLevel;
                    if (blockLevel < 0) blockLevel = 0;
                    L.AddBlock(new BlockObj(point - fixedV2, block.size, forward, blockLevel));
                }
            }

            using (var itor = ForEachWall()) {
                while (itor.MoveNext()) {
                    var wall = itor.Current;
                    var center = (wall.start + wall.end) / 2f;
                    var size2d = wall.end - wall.start;
                    Vector size = size2d;
                    if (size2d.x == 0) {
                        size.z = Mathf.Abs(size2d.y);
                    } else {
                        size.x = Mathf.Abs(size2d.x);
                    }
                    L.AddBlock(new BlockObj(center - fixedV2, size, forward, (int)wall.blockLevel));
                }
            }
            
            m_Reedbeds.Clear();

            GetComponentsInChildren(m_Reedbeds);
            
            GenEdgeMesh();

            StartCoroutine(GenDynamicObjects());
        }

        public void GenNavMeshBuildSources(List<NavMeshBuildSource> sources)
        {
            for (int i = 0; i < blocks.Count; ++i) {
                var block = blocks[i];
                if (block.blockLevel < BlockLevel.Block) continue;

                var center = block.start + block.size / 2;
                var wcenter = transform.TransformPoint(new Vector3(center.x, 0, center.y));
                var size = block.size;                
                sources.Add(new NavMeshBuildSource {
                    shape = NavMeshBuildSourceShape.ModifierBox,
                    area = 1, // Not Walkable
                    component = this,
                    transform = Matrix4x4.TRS(wcenter, transform.rotation, Vector3.one),
                    size = new Vector3(size.x, 5, size.y),
                });
            }

            for (int i = 0; i < walls.Count; ++i) {
                var wall = walls[i];
                var center = (wall.start + wall.end) / 2;
                var wcenter = transform.TransformPoint(new Vector3(center.x, 0, center.y));
                var size = wall.start - wall.end;
                if (size.x < 0) size.x = -size.x; else if (size.x == 0) size.x = 0.1f;
                if (size.y < 0) size.y = -size.y; else if (size.y == 0) size.y = 0.1f;
                sources.Add(new NavMeshBuildSource {
                    shape = NavMeshBuildSourceShape.ModifierBox,
                    area = 1, // Not Walkable
                    component = this,
                    transform = Matrix4x4.TRS(wcenter, transform.rotation, Vector3.one),
                    size = new Vector3(size.x, 5, size.y),
                });
            }
            
            if (Shared != null && Shared != this) {
                Shared.GenNavMeshBuildSources(sources);
            }
        }

        private void GenEdgeMesh()
        {
            const float edgeWidth = 15f;
            const float innerWidth = 5f;
            const float height = 0.05f;

            var filter = gameObject.AddComponent(typeof(MeshFilter)) as MeshFilter;
            var outSize = m_Size + new Vector2(edgeWidth, edgeWidth);
            var innerSize = m_Size - new Vector2(innerWidth, innerWidth);
            Vector3 outZero = new Vector3(-edgeWidth, height, -edgeWidth),
                    outRight = new Vector3(outSize.x, height, -edgeWidth),
                    outOne = new Vector3(outSize.x, height, outSize.y),
                    outUp = new Vector3(-edgeWidth, height, outSize.y);

            var mesh = new Mesh() { name = "MapEdge" };
            var v3s = new List<Vector3> {
                    new Vector3(-edgeWidth, height, innerWidth),
                    new Vector3(outSize.x, height, innerWidth), outRight, outZero,
                    new Vector3(innerSize.x, height, -edgeWidth),
                    new Vector3(innerSize.x, height, outSize.y), outOne, outRight,
                    new Vector3(outSize.x, height, innerSize.y),
                    new Vector3(-edgeWidth, height, innerSize.y), outUp, outOne,
                    new Vector3(innerWidth, height, outSize.y),
                    new Vector3(innerWidth, height, -edgeWidth), outZero, outUp,
                };
            mesh.SetVertices(v3s);

            Color InnerC = new Color(1, 1, 1, 0.0f);
            Color OuterC = Color.white;

            mesh.SetColors(new List<Color> {
                InnerC, InnerC, OuterC, OuterC,
                InnerC, InnerC, OuterC, OuterC,
                InnerC, InnerC, OuterC, OuterC,
                InnerC, InnerC, OuterC, OuterC,
            });

            // 15/10    12/9    8/5     11/6
            //
            // 14/3     13/0    1/4     2/7 
            var triangles = new List<int> {
                    0, 1, 2, 2, 3, 0,
                    4, 5, 6, 6, 7, 4,
                    8, 9, 10, 10, 11, 8,
                    12, 13, 14, 14, 15, 12,
                };
            mesh.SetTriangles(triangles, 0);
            mesh.uv = new Vector2[] {
                Vector2.one, Vector2.right, Vector2.zero, Vector2.up,
                Vector2.one, Vector2.right, Vector2.zero, Vector2.up,
                Vector2.one, Vector2.right, Vector2.zero, Vector2.up,
                Vector2.one, Vector2.right, Vector2.zero, Vector2.up,
            };

            mesh.RecalculateNormals();

            filter.sharedMesh = mesh;

            var rdr = gameObject.AddComponent(typeof(MeshRenderer)) as MeshRenderer;
            rdr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            rdr.receiveShadows = false;
            rdr.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            rdr.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;
            rdr.material = m_EdgeMat ? m_EdgeMat : Control.Creator.objL.Get("MapEdge") as Material;
        }

        private IEnumerator GenDynamicObjects()
        {
            if (!string.IsNullOrEmpty(m_MiniMap)) {
                yield return AssetsMgr.A.Loader.LoadingAsset(typeof(Texture), m_MiniMap);
                mapTex = AssetsMgr.A.Loader.loadedObj as Texture;
            }

            var list = new List<IDynamicAsset>();
            GetComponentsInChildren(list);
            list.Sort((a, b) => string.CompareOrdinal(a.assetPath, b.assetPath));
            string currPath = null;
            Object currAsset = null;
            foreach (var dyAsset in list) {
                if (currPath != dyAsset.assetPath) {
                    currPath = dyAsset.assetPath;
                    yield return AssetsMgr.A.Loader.LoadingAsset(typeof(GameObject), currPath);
                    currAsset = AssetsMgr.A.Loader.loadedObj as Object;
                }
                dyAsset.OnAssetLoaded(currAsset);
            }

            inited = true;
        }
        
        public void LoadReedView(Stage L, ReedObj reedObj, Vector offset)
        {
            var group = reedObj.group;
            foreach (var reed in m_Reedbeds) {
                if (reed.group == group) {
                    reed.LoadView();
                    reed.Subscribe(reedObj);
                    L.AddReedbed(reedObj.id, reed.ToPolygon(offset));
                }
            }
        }

        public void UnloadReedView(Stage L, ReedObj reedObj)
        {
            var group = reedObj.group;
            foreach (var reed in m_Reedbeds) {
                if (reed.group == group) {
                    reed.UnloadView();
                    reed.Unsubscribe();
                }
            }
            L.RemoveReedbed(group);
        }

        public void DrawMiniReed(int group, System.Action<ReedEdit, int, int> drawer)
        {
            foreach (var reed in m_Reedbeds) {
                if (reed.group == group) {
                    reed.HandlerGrids(this, drawer);
                }
            }
        }

        public override string ToString()
        {
            return string.Format("[Stage#{0}]", templateId);
        }

#if UNITY_EDITOR

        private Vector3 DrawAreaGizmo(Area area, Color color, bool dotted)
        {
            var pos = m_Start.position;
            var unitOffset = new Vector3(0.5f, 0, 0.5f);

            var center = new Vector3(area.coord.x, 0.01f, area.coord.y) + unitOffset;
            if (area.param.y > 0) {
                GizmosTools.DrawRect(pos + m_Start.rotation * center, m_Start.rotation, area.param.x, area.param.y, color);
            } else {
                GizmosTools.DrawCircle(pos + m_Start.rotation * center, m_Start.rotation, area.param.x, color, dotted);
            }
            return center;
        }
        
        public void DrawGizmosSelected()
        {
            if (m_Start) {
                var matrix = Gizmos.matrix;
                var color = Gizmos.color;

                var pos = m_Start.position;
                var selfMatrix = Matrix4x4.TRS(pos, m_Start.rotation, Vector3.one);
                Gizmos.matrix = selfMatrix;

                Gizmos.color = new Color(0, 0, 0, 0.3f);
                var size = new Vector3(m_Size.x, 0, m_Size.y);
                Gizmos.DrawCube(size / 2, size);

                Gizmos.color = new Color(0f, 0f, 0f, 0.5f);
                for (int i = 0; i <= size.x; ++i) {
                    Gizmos.DrawLine(new Vector3(i, 0, 0), new Vector3(i, 0, size.z));
                }

                for (int j = 0; j <= size.z; ++j) {
                    Gizmos.DrawLine(new Vector3(0, 0, j), new Vector3(size.x, 0, j));
                }

                foreach (Transform t in transform) {
                    var reed = t.GetComponent(typeof(ReedEdit)) as ReedEdit;
                    if (reed) reed.DrawGizmos();
                }

                Gizmos.matrix = selfMatrix;

                Gizmos.color = color;
                Gizmos.matrix = matrix;
            }
        }
        
        private void OnDrawGizmosSelected()
        {
            if (UnityEditor.Selection.activeGameObject == gameObject) {
                DrawGizmosSelected();
            }
        }
#endif

    }
}
