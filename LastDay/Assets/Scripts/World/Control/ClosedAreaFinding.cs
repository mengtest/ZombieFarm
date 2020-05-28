using System.Collections;
using System.Collections.Generic;
using ILuaState = System.IntPtr;
using XLua;

namespace World.Control
{
    public class ClosedAreaFinding : WAStarFindPath.IWMapInfo
    {
        private WAStarFindPath m_AStar;
        private WPoint m_Start = new WPoint();
        private WPoint m_End = new WPoint(0, 0);
        private List<int> m_OpenList = new List<int>();

        private int m_Col, m_Row;
        private LuaTable m_Stage;

        public ClosedAreaFinding(LuaTable stage)
        {
            m_AStar = new WAStarFindPath {
                enableDebug = true
            };

            m_Stage = stage;

            // 查找范围包括了不可建造的边缘格子
            var lua = m_Stage.PushField("get_build_size");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.ExecPCall(1, 2, b);
            var width = lua.ToInteger(-2) / 2;
            var height = lua.ToInteger(-1) / 2;
            lua.Pop(2);

            m_Col = width + 2;
            m_Row = height + 2;
        }

        public void Uninit()
        {
            m_Stage.Dispose();
        }

        public int cols() { return m_Col; }

        public int rows() { return m_Row; }

        private void Grid2Coord(ref int value)
        {
            value = value * 2 - 2;
        }

        private void Coord2Grid(ref int value)
        {
            value = (value + 2) / 2;
        }

        private void Index2Coord(int index, out int x, out int y)
        {
            var lua = m_Stage.PushField("index2coord");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.PushInteger(index);
            lua.ExecPCall(2, 2, b);
            x = lua.ToInteger(-2);
            y = lua.ToInteger(-1);
            lua.Pop(2);
        }

        private void Coord2Index(int x, int y, out int index)
        {
            var lua = m_Stage.PushField("coord2index");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.PushInteger(x);
            lua.PushInteger(y);
            lua.ExecPCall(3, 1, b);
            index = lua.ToInteger(-1);
            lua.Pop(1);
        }

        private void Grid2Index(int x, int y, out int index)
        {
            Grid2Coord(ref x); Grid2Coord(ref y);
            Coord2Index(x, y, out index);
        }

        private bool HasWall(int fx, int fy, int nx, int ny)
        {
            var lua = m_Stage.PushField("has_wall");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.PushInteger(fx);
            lua.PushInteger(fy);
            lua.PushInteger(nx);
            lua.PushInteger(ny);
            lua.ExecPCall(5, 1, b);
            var ret = !lua.IsNil(-1);
            lua.Pop(1);
            return ret;
        }

        private bool HasFloor(int nx, int ny)
        {
            var lua = m_Stage.PushField("has_floor");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.PushInteger(nx);
            lua.PushInteger(ny);
            lua.ExecPCall(3, 1, b);
            var ret = !lua.IsNil(-1);
            lua.Pop(1);

            return ret;
        }

        private bool m_Last;

        private bool Found(int nx, int ny, int ex, int ey)
        {
            return !m_Last;
        }

        public bool isBlocked(int fx, int fy, int nx, int ny, int radius)
        {
            // 不允许斜向移动
            if (fx != nx && fy != ny) return true;

            Grid2Coord(ref fx);
            Grid2Coord(ref fy);
            Grid2Coord(ref nx);
            Grid2Coord(ref ny);

            if (HasWall(fx, fy, nx, ny)) return true;

            m_Last = HasFloor(nx, ny);
            if (m_Last) {
                int index;
                Coord2Index(nx, ny, out index);
                if (m_OpenList.Contains(index)) {
                    m_Last = false;
                }
            }

            return false;
        }

        public void Update()
        {
            m_OpenList.Clear();
            var list = new List<int>();

            WAStarFindPath.FoundDelegate found = Found;
            var lua = LuaComponent.lua;
            m_Stage.push(lua);
            lua.PushString("ClosedArea");
            lua.NewTable();
            lua.SetTable(-3);
            lua.Pop(1);
            
            for (int n = 0; ; ++n) {
                m_Stage.PushField("Floors");
                int index = -1;
                lua.PushNil();
                while (lua.Next(-2)) {
                    var key = lua.ToInteger(-2);
                    lua.Pop(1);
                    if (!list.Contains(key)) {
                        list.Add(key);
                        index = key;
                        lua.Pop(1);
                        break;
                    }
                }
                lua.Pop(1);

                if (index < 0) break;

                int x, y;
                Index2Coord(index, out x, out y);

                m_Last = true;
                Coord2Grid(ref x); Coord2Grid(ref y);
                m_Start.Update(x, y, null);
                var path = m_AStar.findPath(this, 0, m_Start, m_End, found);
                if (path == null) {
                    m_Stage.PushField("ClosedArea");
                    lua.PushInteger(lua.ObjLen(-1) + 1);
                    if (m_AStar.testList.Count > 0) {
                        lua.CreateTable(m_AStar.testList.Count, 0);
                        for (int i = 0; i < m_AStar.testList.Count; ++i) {
                            var p = m_AStar.testList[i];
                            Grid2Index(p.x, p.y, out index);
                            list.Add(index);
                            lua.SetNumber(-1, i + 1, index);
                            //LogMgr.D("{0}:{1}", n, p);
                        }
                    } else {
                        lua.CreateTable(1, 0);
                        Grid2Index(m_Start.x, m_Start.y, out index);
                        lua.SetNumber(-1, 1, index);
                        //LogMgr.D("{0}:{1}", n, m_Start);
                    }                    
                    lua.SetTable(-3);
                    lua.Pop(1);
                } else {
                    // 走过的点加入开放列表，不再处理。
                    m_OpenList.Add(index);
                    foreach (var p in m_AStar.testList) {
                        Coord2Index(p.x, p.y, out index);
                        m_OpenList.Add(index);
                    }
                }
            }

            m_Stage.PushField("closed_area_updated");
            var b = lua.BeginPCall();
            m_Stage.push(lua);
            lua.ExecPCall(1, 0, b);
        }
    }
}
