//
//  Debuger.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using Dest.Math;
using Vectrosity;

namespace World.View
{
    using Control;

    public class Debugger : MonoSingleton<Debugger>
    {
        private const int CIRCLE_POINTS = 33;
        private const int RECT_POINTS = 7;
        private const int ALERT_POINTS = 33;

        private class EntityLine
        {
            private IEntity m_Entity;
            private VectorLine m_Size, m_Alert, m_Sight;
            public EntityLine(IEntity entity)
            {
                m_Entity = entity;
                var size = entity.size;
                var cap = Math.IsEqual(size.x, size.z) ? CIRCLE_POINTS : RECT_POINTS;
                m_Size = new VectorLine("OBJ#" + entity.id, new List<Vector3>(cap), 1) {
                    lineType = LineType.Continuous,
                    material = lineMat,
                    color = Color.white,
                };
                m_Size.rectTransform.SetParent(Instance.m_Root, false);

                if (entity.camp != 0) {
                    var alert = entity.GetAttr(ATTR.dayAlert);
                    if (alert > 0) {
                        m_Alert = new VectorLine("ALERT#" + entity.id, new List<Vector3>(ALERT_POINTS), 1) {
                            lineType = LineType.Continuous,
                            material = lineMat,
                            color = Color.white
                        };
                        m_Alert.rectTransform.SetParent(Instance.m_Root, false);
                    }

                    var sight = entity.GetAttr(ATTR.daySightRad);
                    var sightAngle = entity.GetAttr(ATTR.daySightAngle);
                    if (sight > 0 && sightAngle > 0) {
                        m_Sight = new VectorLine("SIGHT#" + entity.id, new List<Vector3>(ALERT_POINTS), 1) {
                            lineType = LineType.Continuous,
                            material = lineMat,
                            color = Color.white
                        };
                        m_Sight.rectTransform.SetParent(Instance.m_Root, false);
                    }
                }
            }

            public void Update()
            {
                var visible = m_Entity.IsAlive() && !m_Entity.IsNull() && m_Entity.view.IsVisible();

                var entity = m_Entity;
                Vector3 coord = entity.coord;
                Vector3 forward = entity.forward;
                var angles = Vector3.SignedAngle(StageView.FwdLocal2World(forward), Vector3.forward, Vector3.up);
                var center = StageView.Local2World(coord);
                center.y += 0.01f;

                m_Size.active = visible;
                var line = m_Size;
                if (line.points3.Count == CIRCLE_POINTS) {
                    var radius = entity.GetRadius();
                    line.MakeCircle(center, Vector3.up, radius, line.points3.Count - 3, angles);
                    line.points3[line.points3.Count - 2] = center;
                    line.points3[line.points3.Count - 1] = StageView.Local2World(coord + forward * (radius + 0.5f));
                } else {
                    var offset = (Vector3)entity.size / 2;
                    if (offset.x == 0) offset.x = 0.1f;
                    offset.y = 0f;

                    var rot = Quaternion.FromToRotation(Vector3.forward, forward);

                    var bottomLeft = coord - rot * offset;
                    var topRight = coord + rot * offset;

                    offset.x = -offset.x;
                    var bottomRight = coord - rot * offset;
                    var topLeft = coord + rot * offset;
                    var topCenter = coord + forward * offset.z;
                    var topForward = coord + forward * (offset.z + 0.5f);

                    line.points3[0] = StageView.Local2World(topLeft);
                    line.points3[1] = StageView.Local2World(topRight);
                    line.points3[2] = StageView.Local2World(bottomRight);
                    line.points3[3] = StageView.Local2World(bottomLeft);
                    line.points3[4] = line.points3[0];
                    line.points3[5] = StageView.Local2World(topCenter);
                    line.points3[6] = StageView.Local2World(topForward);
                }

                if (m_Alert != null) {
                    m_Alert.active = visible;
                    if (visible) {
                        float alertRange;
                        var human = entity as Human;
                        if (human != null) {
                            alertRange = StageCtrl.clientVision;
                        } else {
                            alertRange = DayNightView.Instance.dayNight == DayNightView.EDayNight.Night
                                ? entity.GetAttr(ATTR.nightAlert)
                                : entity.GetAttr(ATTR.dayAlert);
                        }
                        m_Alert.MakeCircle(center, Vector3.up, alertRange, line.points3.Count - 1);
                    }
                }
                if (m_Sight != null) {
                    m_Sight.active = visible;
                    if (visible) {
                        float sight, halfAngle;
                        if (DayNightView.Instance.dayNight == DayNightView.EDayNight.Night) {
                            sight = entity.GetAttr(ATTR.nightSightRad);
                            halfAngle = entity.GetAttr(ATTR.nightSightAngle) / 2f;
                        } else {
                            sight = entity.GetAttr(ATTR.daySightRad);
                            halfAngle = entity.GetAttr(ATTR.daySightAngle) / 2f;
                        }
                        m_Sight.MakeArc(center, Vector3.up,
                            sight, sight, -halfAngle - angles, halfAngle - angles,
                            m_Sight.points3.Count - 3, 1);
                        m_Sight.points3[0] = center;
                        m_Sight.points3[m_Sight.points3.Count - 1] = center;
                    }
                }
            }

            public void Draw()
            {
                if (m_Size.active) m_Size.Draw3D();
                if (m_Alert != null && m_Alert.active) m_Alert.Draw3D();
                if (m_Sight != null && m_Sight.active) m_Sight.Draw3D();
            }

            public void SetVisible(bool visible)
            {
                m_Size.active = visible;
                if (m_Alert != null) m_Alert.active = visible;
                if (m_Sight != null) m_Sight.active = visible;
            }

            public void Uninit()
            {
                VectorLine.Destroy(ref m_Size);
                VectorLine.Destroy(ref m_Alert);
                VectorLine.Destroy(ref m_Sight);
                m_Entity = null;
            }
        }

        public static Material lineMat {
            get {
                return Creator.objL.Get("GroundLine") as Material;
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void LogE(string fmt, params object[] args)
        {
            fmt = string.Format("[{0:0000}]{1}", StageView.L != null ? StageView.L.frameIndex : 0, fmt);
            UnityEngine.Debug.LogErrorFormat(fmt, args);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void LogW(string fmt, params object[] args)
        {
            fmt = string.Format("[{0:0000}]{1}", StageView.L != null ? StageView.L.frameIndex : 0, fmt);
            UnityEngine.Debug.LogWarningFormat(fmt, args);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void LogD(string fmt, params object[] args)
        {
            fmt = string.Format("[{0:0000}]{1}", StageView.L != null ? StageView.L.frameIndex : 0, fmt);
            UnityEngine.Debug.LogFormat(fmt, args);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void LogI(string fmt, params object[] args)
        {
            if (StageCtrl.debug) {
                fmt = string.Format("[{0:0000}]{1}", StageView.L != null ? StageView.L.frameIndex : 0, fmt);
                UnityEngine.Debug.LogFormat(fmt, args);
            }
        }


        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void Init(IEntity entity)
        {
            if (Instance && entity != null) Instance.InitObj(entity);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void Uninit(IEntity entity)
        {
            if (Instance && entity != null) Instance.UninitObj(entity);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void Update(IEntity entity)
        {
            if (Instance && StageCtrl.unitGuideLine && entity != null) Instance.UpdateObj(entity);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void Draw(ref Shape2D shape, Color color, float time)
        {
            if (StageCtrl.debug && Instance) {
                switch (shape.type) {
                    case ShapeType.Segment:
                        var line = shape.segment;
                        DrawLine(color, time, line.P0, line.P1);
                        break;
                    case ShapeType.AAB:
                        var aab = shape.aab;
                        DrawRect(color, time, new Box2(aab));
                        break;
                    case ShapeType.Box:
                        DrawRect(color, time, shape.box);
                        break;
                    case ShapeType.Circle:
                        var circle = shape.circle;
                        DrawCircle(color, time, circle.Center, circle.Radius);
                        break;
                    case ShapeType.Sector:
                        DrawSector(color, time, shape.circle, shape.forward, shape.angle);
                        break;
                    case ShapeType.Annulus:
                        DrawAnnulus(color, time, shape.circle.Center, shape.innerCircle.Radius, shape.circle.Radius);
                        break;
                    default: break;
                }
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void Draw(Shape2D shape, Color color, float time)
        {
            Draw(ref shape, color, time);
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawLine(Color color, float time, Vector from, Vector to)
        {
            if (StageCtrl.debug && Instance) {
                var line = VectorLine.SetLine3D(color, time,
                    StageView.Local2World(from), StageView.Local2World(to));
                line.material = lineMat;
                line.rectTransform.SetParent(Instance.m_Root, false);
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawCircle(Color color, float time, Vector pos, float radius)
        {
            if (StageCtrl.debug && Instance) {
                var origin = StageView.Local2World(pos);
                var line = new VectorLine("_CIRCLE", new List<Vector3>(30), 1f, LineType.Continuous) {
                    material = lineMat,
                    color = color
                };
                line.MakeCircle(origin, Vector3.up, radius);
                line.Draw3DAuto(time);
                line.rectTransform.SetParent(Instance.m_Root, false);
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawRect(Color color, float time, Box2 box)
        {
            if (StageCtrl.debug && Instance) {
                Vector2 v0, v1, v2, v3;
                box.CalcVertices(out v0, out v1, out v2, out v3);
                Vector3[] V3 = new Vector3[5];
                V3[0] = StageView.Local2World(new Vector(v0.x, v0.y));
                V3[1] = StageView.Local2World(new Vector(v1.x, v1.y));
                V3[2] = StageView.Local2World(new Vector(v2.x, v2.y));
                V3[3] = StageView.Local2World(new Vector(v3.x, v3.y));
                V3[4] = StageView.Local2World(new Vector(v0.x, v0.y));

                var line = VectorLine.SetLine3D(color, time, V3);
                line.material = lineMat;
                line.rectTransform.SetParent(Instance.m_Root, false);
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawPolygon(Color color, float time, params Vector[] V)
        {
            if (StageCtrl.debug && Instance) {
                Vector3[] V3 = new Vector3[V.Length + 1];
                for (int i = 0; i < V.Length; ++i) {
                    V3[i] = StageView.Local2World(V[i]);
                }
                V3[V.Length] = V3[0];

                var line = VectorLine.SetLine3D(color, time, V3);
                line.material = lineMat;
                line.rectTransform.SetParent(Instance.m_Root, false);
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawSector(Color color, float time, Circle2 circle, Vector forward, float angle)
        {
            if (StageCtrl.debug && Instance) {
                var line = new VectorLine("_SECTOR", new List<Vector3>(30), 1f, LineType.Continuous) {
                    material = lineMat,
                    color = color
                };

                var center = StageView.Local2World(circle.Center);
                var radius = circle.Radius;
                var angles = Vector3.SignedAngle(StageView.FwdLocal2World(forward), Vector3.forward, Vector3.up);
                var halfAngle = angle / 2f;
                line.MakeArc(center, Vector3.up,
                    radius, radius, -halfAngle - angles, halfAngle - angles,
                    line.points3.Count - 3, 1);
                line.points3[0] = center;
                line.points3[line.points3.Count - 1] = center;
                line.Draw3DAuto(time);
                line.rectTransform.SetParent(Instance.m_Root, false);
            }
        }

        [Conditional(LogMgr.DEBUG), Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void DrawAnnulus(Color color, float time, Vector pos, float innerRadius, float outerRadius)
        {
            DrawCircle(color, time, pos, innerRadius);
            DrawCircle(color, time, pos, outerRadius);
        }

        private void InitObj(IEntity entity)
        {
            if (entity != null && !m_Objs.ContainsKey(entity)) {
                var line = new EntityLine(entity);
                m_Objs.Add(entity, line);
                line.Update();
            }
        }

        private void UninitObj(IEntity entity)
        {
            if (entity != null) {
                EntityLine line;
                if (m_Objs.TryGetValue(entity, out line)) {
                    line.Uninit();
                    m_Objs.Remove(entity);
                }
            }
        }

        private void UpdateObj(IEntity entity)
        {
            if (entity != null) {
                EntityLine line;
                if (m_Objs.TryGetValue(entity, out line)) {
                    line.Update();
                }
            }
        }

        private Dictionary<IEntity, EntityLine> m_Objs = new Dictionary<IEntity, EntityLine>();

        protected override void Awaking()
        {
            base.Awaking();
            ZFrame.UIManager.Instance.RegDrawGUI(DrawGUI);
        }

        private VectorLine m_Map;
        private RectTransform m_Root;

        private void Start()
        {
            // 地图线

            var offset = new Vector3(-0.5f, 0, -0.5f);
            m_Map = new VectorLine("MAPGRID", new List<Vector3>(), 1, LineType.Discrete) {
                color = Color.gray,
            };
            float width = Map.size.x, height = Map.size.z;
            for (int x = 0; x <= width; ++x) {
                m_Map.points3.Add(StageView.Local2World(new Vector(x, 0, 0)) + offset);
                m_Map.points3.Add(StageView.Local2World(new Vector(x, 0, height)) + offset);
            }
            for (int z = 0; z <= height; ++z) {
                m_Map.points3.Add(StageView.Local2World(new Vector(0, 0, z)) + offset);
                m_Map.points3.Add(StageView.Local2World(new Vector(width, 0, z)) + offset);
            }

            m_Root = m_Map.rectTransform;
        }

        // Update is called once per frame
        private void Update()
        {
            if (StageCtrl.debug) {
                m_Map.Draw3D();
            }
            if (StageCtrl.unitGuideLine) {
                foreach (var line in m_Objs.Values) {
                    line.Draw();
                }
            }
        }

        private void OnDestroy()
        {
            VectorLine.Destroy(ref m_Map);
            if (ZFrame.UIManager.Instance) {
                ZFrame.UIManager.Instance.UnregDrawGUI(DrawGUI);
            }
        }

        private bool m_ShowWeather;
        private int m_Weather = -1;
        private GUIContent[] m_WeatherFxes = {
            new GUIContent("雨1", "mapweather_rainy1"),
            new GUIContent("沙1", "mapweather_sandy1"),
            new GUIContent("雪1", "mapweather_snowy1"),
            new GUIContent("风1", "mapweather_windy1"),
        };

        private void DrawGUI()
        {
            if (StageCtrl.L == null) return;

            var tglValue = GUILayout.Toggle(StageCtrl.debug, "调试信息");
            if (tglValue != StageCtrl.debug) {
                StageCtrl.debug = tglValue;
                StageCtrl.S.debug = tglValue;
                m_Map.active = tglValue;
            }

            tglValue = GUILayout.Toggle(StageCtrl.unitGuideLine, "单位辅助线");
            if (tglValue != StageCtrl.unitGuideLine) {
                StageCtrl.unitGuideLine = tglValue;
                foreach (var line in m_Objs.Values) {
                    line.SetVisible(tglValue);
                }
            }

            var dnv = DayNightView.Instance;
            var dayNight = GUILayout.Toggle(StageCtrl.DayNight, "昼夜系统");
            if (StageCtrl.DayNight != dayNight) {
                StageCtrl.DayNight = dayNight;
                if (dnv) dnv.SetFixTime(dayNight ? -1f : 0.5f);
            }

            if (!dayNight && dnv) {
                GUILayout.BeginHorizontal();
                var progress = GUILayout.HorizontalSlider(dnv.setProgress, 0, 1, GUILayout.Width(100));
                dnv.setProgress = Mathf.Round(progress * 1000) / 1000f;
                GUILayout.Label(dnv.setProgress.ToString());
                GUILayout.EndHorizontal();
            }
            
            var hideObjOnOutScreen = GUILayout.Toggle(StageCtrl.hideObjOnOutScreen, "隐藏屏幕外的单位");
            if(hideObjOnOutScreen != StageCtrl.hideObjOnOutScreen) {
                StageCtrl.hideObjOnOutScreen = hideObjOnOutScreen;
                if (!hideObjOnOutScreen) {
                    using (var itor = StageCtrl.L.ForEachObj()) {
                        while (itor.MoveNext()) {
                            var obj = itor.Current;
                            var view = obj.view as EntityView;
                            if (view && view.control == null && !view.loading) {
                                Creator.LoadObjView(view, view.model);
                                MiniMap.Instance.Enter(obj);
                            }
                        }
                    }
                }
            }

            var enableFOW = GUILayout.Toggle(StageCtrl.enableFOW, "显示战争迷雾");
            if(enableFOW != StageCtrl.enableFOW) {
                StageCtrl.enableFOW = enableFOW;
                StageCtrl.showFogOfWar = StageCtrl.showFogOfWar;
            }

            var showWeather = GUILayout.Toggle(m_ShowWeather, "预览天气效果");
            if (showWeather != m_ShowWeather) {
                m_ShowWeather = showWeather;
                if (!showWeather) {
                    WeatherView.LoadWeather(null);
                    m_Weather = -1;
                }
            }
            if (m_ShowWeather) {
                var weather = GUILayout.SelectionGrid(m_Weather, m_WeatherFxes, 4);
                if (weather != m_Weather) {
                    m_Weather = weather;
                    var fx = m_WeatherFxes[weather];
                    WeatherView.LoadWeather(fx.tooltip);
                }
            }
        }
    }
}
