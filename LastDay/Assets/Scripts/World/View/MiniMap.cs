//
//  MiniMap.cs
//  survive
//
//  Created by xingweizhen on 10/27/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ZFrame;
using ZFrame.UGUI;
using Dest.Math;

namespace World.View
{
    using Control;

    public class MiniMap : MonoSingleton<MiniMap>
    {
        private const int MAP_TEX_SIZE = 1024;
        private const int PIXEL_PER_UNIT = 5;

        private class MapUnit
        {
            private string m_SpritePath;
            public UISprite mark;

            public IEntity ent { get; private set; }            
            /// <summary>
            /// 单位图标的朝向是否要和实际朝向同步
            /// </summary>
            public bool directional { get; private set; }
            /// <summary>
            /// 当单位在小地图外面时，是否在地图边缘产生一个指示器。
            /// </summary>
            public string itorSprite { get; private set; }

            private bool m_Indicating;
            public bool indicating {
                get { return m_Indicating; }
                set {
                    if (m_Indicating != value) {
                        m_Indicating = value;
                        mark.SetSprite(value ? itorSprite : m_SpritePath);
                        mark.SetNativeSize();
                    }
                }
            }

            public void Set(IEntity ent, string spritePath, string indicate)
            {
                this.ent = ent;
                mark.SetSprite(spritePath);
                mark.SetNativeSize();

                directional = spritePath.OrdinalEndsWith("_d");
                if (!directional) {
                    mark.rectTransform.localRotation = Quaternion.identity;
                }

                itorSprite = indicate;
                m_SpritePath = spritePath;
                m_Indicating = false;
            }

            public void Unset()
            {
                ent = null;
                mark = null;
            }
        }

        private Pool<MapUnit> m_UnitPool;

        [SerializeField] private UITexture m_Lay;
        [SerializeField] private UITexture m_Map;
        [SerializeField] private UITexture m_Mask;

        [SerializeField] private UISprite m_Mark;

        [SerializeField] private float m_MapScale = 1f;

        [SerializeField] private Color m_EmptyColor = new Color(232 / 255f, 232 / 255f, 212 / 255f, 0.75f);

        [SerializeField] private Color m_BlockColor = Color.black;

        [SerializeField] private Color m_OutsideColor = Color.clear;

        private float m_MiniSize = 160;
        [SerializeField] private float m_FullSize = 600;

        [SerializeField]private RectOffset m_ItorAreaPadding;

        private ObjPool<UISprite> m_MarkPool;
        private readonly List<MapUnit> m_Units = new List<MapUnit>();
        private IEntity m_Center;
        private Transform m_CamTrans;
        private Quaternion m_UnitRot;
        private Texture2D m_MapTex;
        private Texture m_MapBgTex;
        private Vector m_MapCenter;

        private int m_SW, m_SH;
        private Color m_Empty, m_Outside, m_Block;

        private AAB2 m_Area;

        private void DrawReedbed(ReedEdit reed, int x, int y)
        {
            var startX = m_SW + x * PIXEL_PER_UNIT;
            var startY = m_SW + y * PIXEL_PER_UNIT;
            for (int i = startX; i < startX + PIXEL_PER_UNIT; ++i) {
                for (int j = startY; j < startY + PIXEL_PER_UNIT; ++j) {
                    m_MapTex.SetPixel(i, j, reed.color);
                }
            }
        }

        private void EraseReedbed(ReedEdit reed, int x, int y)
        {
            var startX = m_SW + x * PIXEL_PER_UNIT;
            var startY = m_SW + y * PIXEL_PER_UNIT;
            for (int i = startX; i < startX + PIXEL_PER_UNIT; ++i) {
                for (int j = startY; j < startY + PIXEL_PER_UNIT; ++j) {
                    m_MapTex.SetPixel(i, j, m_Empty);
                }
            }
        }

        public void InitMap(StageEdit edit)
        {
            enabled = true;
            
            m_MapCenter = (edit.size - Vector2.one) / 2f;

            int w = (int)edit.size.x * PIXEL_PER_UNIT;
            int h = (int)edit.size.y * PIXEL_PER_UNIT;
            m_SW = (m_MapTex.width - w) / 2;
            m_SH = (m_MapTex.height - h) / 2;
            var bW = m_SW + w;
            var bH = m_SH + h;

            m_Empty = m_EmptyColor;
            m_Outside = m_OutsideColor;
            m_Block = m_BlockColor;            
            if (StageMapTexture.Instance) {
                StageMapTexture.Instance.Init(edit);
                m_Lay.texture = edit.mapTex ? edit.mapTex : StageMapTexture.Instance.texture;
                m_Empty.a = 0;
                m_Block.a = 0;
            } else {
                m_Lay.texture = null;                
            }

            // Inside
            for (int i = 0; i < m_MapTex.width; ++i) {
                for (int j = 0; j < m_MapTex.height; ++j) {
                    if (i >= m_SW && i <= bW && j >= m_SH && j <= bH) {
                        m_MapTex.SetPixel(i, j, m_Empty);
                    }
                }
            }

            // Blocks
            using (var itor = edit.ForEachBlock()) {
                while (itor.MoveNext()) {
                    var block = itor.Current;
                    var startX = m_SW + (int)block.start.x * PIXEL_PER_UNIT;
                    var startY = m_SH + (int)block.start.y * PIXEL_PER_UNIT;
                    var endX = startX + (int)block.size.x * PIXEL_PER_UNIT;
                    var endY = startY + (int)block.size.y * PIXEL_PER_UNIT;
                    for (int i = startX; i < endX; ++i) {
                        for (int j = startY; j < endY; ++j) {
                            m_MapTex.SetPixel(i, j, m_Block);
                        }
                    }
                }
            }

            // Walls
            using (var itor = edit.ForEachWall()) {
                while (itor.MoveNext()) {
                    var wall = itor.Current;
                    var startX = m_SW + (int)wall.start.x * PIXEL_PER_UNIT;
                    var startY = m_SH + (int)wall.start.y * PIXEL_PER_UNIT;
                    var endX = m_SW + (int)wall.end.x * PIXEL_PER_UNIT;
                    var endY = m_SH + (int)wall.end.y * PIXEL_PER_UNIT;
                    if (startX == endX) {
                        if (startY > endY) {
                            startY = startY + endY;
                            endY = startY - endY;
                            startY = startY - endY;
                        }

                        startX -= 1;
                        endX += 1;
                    } else if (startY == endY) {
                        if (startX > endX) {
                            startX = startX + endX;
                            endX = startX - endX;
                            startX = startX - endX;
                        }

                        startY -= 1;
                        endY += 1;
                    } else {
                        // 不正确的墙壁配置，忽略
                        continue;
                    }

                    for (int i = startX; i < endX; ++i) {
                        for (int j = startY; j < endY; ++j) {
                            m_MapTex.SetPixel(i, j, m_Block);
                        }
                    }
                }
            }

            // OutSide
            for (int i = 0; i < m_MapTex.width; ++i) {
                for (int j = 0; j < m_MapTex.height; ++j) {
                    if (i < m_SW || i > bW || j < m_SH || j > bH) {
                        m_MapTex.SetPixel(i, j, m_Outside);
                    }
                }
            }

            m_MapTex.Apply();
        }

        public void SetMask(Texture maskTex)
        {
            if (m_Mask.texture == null) m_Mask.texture = maskTex;

            EnableMask(StageCtrl.enableFOW && StageCtrl.showFogOfWar);
            FogOfWarEffect.Instance.RegFogUpdated(OnFogTexUpdated);
        }

        public void EnableMask(bool enabled)
        {
            m_Mask.enabled = enabled;
        }

        public void Enter(IObj obj)
        {
            var reedObj = obj as ReedObj;
            if (reedObj != null) {
                StageView.M.DrawMiniReed(reedObj.group, DrawReedbed);
                m_MapTex.Apply();
                return;
            }

            var entity = obj as IEntity;
            if (entity == null) return;
            
            var ico = entity.Data.GetExtend("mapIco");
            if (string.IsNullOrEmpty(ico)) return;

            if (obj is Player) {
                m_Center = entity;
            }

            var minXZ = entity.coord.x + entity.coord.z;
            var maxLayer = 0;
            int siblingIndex = -1;
            for (int i = 0; i < m_Units.Count; ++i) {
                var tarEnt = m_Units[i].ent;
                if (maxLayer < tarEnt.layer) {
                    maxLayer = tarEnt.layer;
                }
                if (entity.layer < maxLayer) break;

                if (entity.layer == maxLayer) {                    
                    var tarCoord = tarEnt.coord;
                    if (minXZ < tarCoord.x + tarCoord.z) {
                        siblingIndex = i;                        
                    }
                } else {
                    siblingIndex = i;
                }
            }
            siblingIndex += 1;

            MapUnit mapUnit = null;
            foreach (var unit in m_Units) {
                if (entity == unit.ent) {
                    mapUnit = unit;
                    break;
                }
            }

            if (mapUnit == null) {
                mapUnit = m_UnitPool.Get();
                if (siblingIndex < m_Units.Count) {
                    m_Units.Insert(siblingIndex, mapUnit);
                } else {
                    m_Units.Add(mapUnit);
                }
            }

            // 需要根据友好规则应用名称
            if (ico.Contains("_c_")) {
                if (obj.camp != m_Center.camp) {
                    if (m_Center.CanInteract(entity) || !entity.offensive) {
                        ico = ico.Replace("_c_", "_o_");
                    } else {
                        ico = ico.Replace("_c_", "_r_");
                    }
                } else {
                    ico = ico.Replace("_c_", "_g_");
                }
            }
            
            var indicate = ((XObject)obj).Data.GetExtend("mapItor");
            mapUnit.Set(entity, ico, indicate);
            // +1 因为底下有map texture
            mapUnit.mark.rectTransform.SetSiblingIndex(siblingIndex + 1);

            if (m_Center != null) {
                UpdateUnitPos(mapUnit);
            }
        }

        public void Exit(IPosition obj, bool forced = false)
        {
            var reedObj = obj as ReedObj;
            if (reedObj != null) {
                StageView.M.DrawMiniReed(reedObj.group, EraseReedbed);
                m_MapTex.Apply();
                return;
            }

            foreach (var unit in m_Units) {
                if (obj == unit.ent) {
                    if (forced || string.IsNullOrEmpty(unit.itorSprite)) {
                        m_Units.Remove(unit);
                        m_UnitPool.Release(unit);
                    }
                    break;
                }
            }
        }

        public void Clear()
        {
            m_Center = null;

            foreach (var unit in m_Units) {
                m_UnitPool.Release(unit);
            }

            m_Units.Clear();

            enabled = false;
        }

        protected override void Awaking()
        {
            base.Awaking();

            m_UnitPool = new Pool<MapUnit>(
                (u) => { u.mark = m_MarkPool.Get(); },
                (u) => {
                    m_MarkPool.Release(u.mark);
                    u.Unset();
                });

            m_MarkPool = new ObjPool<UISprite>(m_Mark,
                (p) => {
                    p.gameObject.SetActive(true);
                    p.Attach(m_Mark.transform.parent);
                },
                (p) => {
                    p.gameObject.SetActive(false);
                    p.transform.SetAsLastSibling();
                });

            m_Mark.gameObject.SetActive(false);

            m_MiniSize = ((RectTransform)transform).rect.width;
        }

        private void OnFogTexUpdated(Texture tex, Material mat)
        {
            var rdrTex = (RenderTexture)m_Mask.texture;
            rdrTex.DiscardContents();
            if (mat) {
                Graphics.Blit(tex, rdrTex, mat);
            } else {
                Graphics.Blit(tex, rdrTex);
            }
        }

        private void UpdateArea(float width, float height)
        {
            var extent = new Vector2(width, height) / 2;
            var minOffset = new Vector2(m_ItorAreaPadding.left, m_ItorAreaPadding.bottom);
            var maxOffset = -new Vector2(m_ItorAreaPadding.right, m_ItorAreaPadding.top);
            m_Area = new AAB2(-extent + minOffset, extent + maxOffset);
        }
        
        private void OnEnable()
        {
            m_MapTex = new Texture2D(MAP_TEX_SIZE, MAP_TEX_SIZE, TextureFormat.RGBA32, false) {
                filterMode = FilterMode.Point,
                wrapMode = TextureWrapMode.Clamp
            };

            m_Map.texture = m_MapTex;
            m_Mask.texture = new RenderTexture(128, 128, 0);

            UpdateArea(m_MiniSize, m_MiniSize);
        }

        private void OnDisable()
        {
            if (FogOfWarEffect.Instance) {
                FogOfWarEffect.Instance.UnregFogUpdated(OnFogTexUpdated);
            }

            if (m_Lay) m_Lay.texture = null;
            
            Destroy(m_Mask.texture);
            Destroy(m_MapTex);
        }

        private Vector2 CalcUnitPos(Vector pos)
        {
            var offset3 = m_UnitRot * (pos - m_Center.pos);
            var offset2 = new Vector2(offset3.x, offset3.z) * m_MapScale;
            return offset2;
        }

        private float CalcForward(Vector3 forward)
        {
            var objFwd = m_UnitRot * forward;
            return Vector3.SignedAngle(objFwd, Vector3.forward, Vector3.up);
        }

        private void SetUnitForward(Transform rect, Vector3 forward)
        {
            rect.localEulerAngles = new Vector3(0, 0, CalcForward(forward));
        }

        private void UpdateMapUV(RawImage uiTex, float mapWidth, float mapHeight, float xOff = 0, float yOff = 0)
        {
            var rect = uiTex.rectTransform.rect;
            var w = rect.width / mapWidth;
            var h = rect.height / mapHeight;
            var offset3 = m_MapCenter - m_Center.pos;
            var offset2 = new Vector2(offset3.x - xOff, offset3.z - yOff) * m_MapScale;
            offset2.x /= mapWidth;
            offset2.y /= mapHeight;
            uiTex.uvRect = new Rect(0.5f - offset2.x - w / 2, 0.5f - offset2.y - h / 2, w, h);
        }

        private void UpdateUnitPos(MapUnit unit)
        {
            var entity = unit.ent;
            var pos = CalcUnitPos(entity.pos);

            var rect = unit.mark.rectTransform;
            if (!string.IsNullOrEmpty(unit.itorSprite) && !m_Area.Contains(pos)) {
                var segment = new Segment2(Vector2.zero, pos);
                Segment2AAB2Intr intr;
                if (Intersection.FindSegment2AAB2(ref segment, ref m_Area, out intr)) {
                    if (intr.Quantity == (int)IntersectionTypes.Segment) {
                        unit.indicating = true;
                        rect.anchoredPosition = intr.Point1;
                        rect.forward = pos.normalized;
                        return;
                    }
                }
            }
            
            unit.indicating = false;
            rect.anchoredPosition = pos;
            if (unit.directional) {
                SetUnitForward(rect, entity.forward);
            }
        }

        private void UpdateUnitRot()
        {
            if (m_CamTrans == null) {
                var mainCam = Camera.main;
                if (mainCam) m_CamTrans = mainCam.transform;
            }

            if (m_CamTrans != null) {
                var forward = m_CamTrans.forward.SetY(0).normalized;
                forward = StageView.FwdWorld2Local(forward);
                m_UnitRot = Quaternion.FromToRotation(forward, Vector3.forward);
            }
        }

        private void Update()
        {
            if (m_Center != null) {
                UpdateUnitRot();
                var mapScale = m_MapScale / PIXEL_PER_UNIT;
                var mapWaith = m_Map.texture.width * mapScale;
                var mapHeight = m_Map.texture.height * mapScale;
                UpdateMapUV(m_Map, mapWaith, mapHeight);
                if (StageMapTexture.Instance) {
                    var offset = StageMapTexture.Instance.offset;
                    var sizex = StageMapTexture.Instance.size.w;
                    var sizey = StageMapTexture.Instance.size.z;
                    UpdateMapUV(m_Lay, sizex * m_MapScale, sizey * m_MapScale, offset.x, offset.y);
                }

                var maskSize = Map.size + Vector.one * StageView.Instance.fogOfWarExtend * 2;
                UpdateMapUV(m_Mask, maskSize.x * m_MapScale, maskSize.z * m_MapScale);

                var mapEuler = new Vector3(0, 0, CalcForward(Vector3.forward));
                m_Map.rectTransform.localEulerAngles = mapEuler;
                m_Lay.rectTransform.localEulerAngles = mapEuler;
                m_Mask.rectTransform.localEulerAngles = mapEuler;

                foreach (var unit in m_Units) UpdateUnitPos(unit);
            }
        }

        public void ToggleMapScale()
        {
            var rect = (RectTransform)transform;
            var size = (int)rect.rect.width;
            var mini = Mathf.Approximately(size, m_FullSize);
            var side = mini ? m_MiniSize : m_FullSize;
            rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, side);
            m_Mask.gameObject.SetActive(mini);
            gameObject.SetEnable(typeof(Mask), mini);

            UpdateArea(side, side);
        }
    }
}
