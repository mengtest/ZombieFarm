using System.Collections;
using System.Collections.Generic;

// warning CS0168: 声明了变量，但从未使用
// warning CS0219: 给变量赋值，但从未使用
#pragma warning disable 0168, 0219 
public class WAStarFindPath
{
    public interface IWMapInfo
    {
        int rows();
        int cols();
        bool isBlocked(int fx, int fy, int tx, int ty, int radius);
    }

    /**
	 * 向各个方向移动计算矩阵
 	 */
    private static readonly int[][] DIREC_MOVE = new int[][] {
        new int[] {0, 0},
        new int[] {-1, 1},
        new int[] {0, 1},
        new int[] {1, 1},
        new int[] {-1, 0},
        new int[] {0, 0},
        new int[] {1, 0},
        new int[] {-1, -1},
        new int[] {0, -1},
        new int[] {1, -1},
    };

    /**
	 * 8方向逆时针序列
	 */
    private static readonly int[] DIREC = new int[] { 1, 2, 3, 6, 9, 8, 7, 4 };
    /**
	 * 方向对应方向序列的index
	 */
    private static readonly int[] DIREC_INX = { -1, 0, 1, 2, 7, -1, 3, 6, 5, 4 };
    /**
	 * 方向搜寻优先矩阵
	 */
    private static readonly int[][] DIREC_COST = new int[][] {
        new int[] {0},
        new int[] {-1,10,8,6,8,-1,4,6,5,0},//1方向
		new int[] {-1,8,10,8,6,-1,6,4,0,4},//2方向
		new int[] {-1,6,8,10,4,-1,8,0,5,6},//3方向
		new int[] {-1,8,6,4,10,-1,0,8,6,4},//4方向
		new int[] {0},
        new int[] {-1,4,6,8,0, -1,10,4,6,8},//6方向
		new int[] {-1,6,5,0,8, -1,4,10,8,6},//7方向
		new int[] {-1,4,0,4,6, -1,6,8,10,8},//8方向
		new int[] {-1,0,5,6,4, -1,8,6,8,10},//9方向
	};

    private int _poolIdx = 0;
    private List<WPoint> m_Pool = new List<WPoint>();
    private WPoint GetPoint(int x, int y, WPoint p)
    {
        WPoint wp = null;
        if (_poolIdx < m_Pool.Count) {
            wp = m_Pool[_poolIdx];
            wp.Update(x, y, p);
        } else {
            wp = new WPoint(x, y, p);
            m_Pool.Add(wp);
        }
        _poolIdx += 1;
        return wp;
    }

    private IWMapInfo _mapInfo;
    private int _objRadius;
    /**
	 * 搜索过的队列标记
	 */
    private bool[] _maskList;
    private List<WPoint> _testList;
    private List<WPoint> _group = new List<WPoint>();
    private List<WPoint> _thePath = new List<WPoint>();
    private WPoint _startPoint;
    private WPoint _endPoint;

    public List<WPoint> testList {  get { return _testList; } }

    public void WAStar()
    {
    }

    bool _enableDebug = false;
    public bool enableDebug {
        set {
            _enableDebug = value;
            if (_enableDebug) {
                _testList = new List<WPoint>();
            } else {
                _testList = null;
            }
        }
    }
    
    private void maskSeach(int x, int y)
    {
        if (_enableDebug) {
            _testList.Add(new WPoint(x, y));
        }
        if (x < 0 || y < 0 || x >= _mapInfo.cols() || y >= _mapInfo.rows()) return;
        _maskList[y * _mapInfo.cols() + x] = true;
    }

    /**
	 * 是否可以进行搜索，搜索过的点不在进行搜索
	 */
    private bool seachBlock(int fx, int fy, int tx, int ty)
    {
        if (tx < 0 || ty < 0 || tx >= _mapInfo.cols() || ty >= _mapInfo.rows()) return true;
        if (_maskList[ty * _mapInfo.cols() + tx]) return true;
        return mapBlock(fx, fy, tx, ty);
    }
    /**
	 * 正向通过和斜向通过条件不一样
	 */
    private bool mapBlock(int fx, int fy, int tx, int ty)
    {
        return _mapInfo.isBlocked(fx, fy, tx, ty, _objRadius);
        //if (_mapInfo.isBlocked(tx, ty, _objRadius)) return true;
        //if (_objRadius == 0) {
        //    if (fx != tx && fy != ty) {
        //        return _mapInfo.isBlocked(fx, ty, _objRadius) && _mapInfo.isBlocked(tx, fy, _objRadius);
        //    }
        //}
        //return false;
    }

    /**
	 * 两个点间是否有一条通道
	 * 优化路径时使用
	 */
    private bool isLinePath(int fx, int fy, int tx, int ty)
    {
        int dx = fx - tx;
        int dy = fy - ty;
        int step = 0;
        if (dx == 0) {
            step = dy > 0 ? -1 : 1;
            for (var ny = fy; ny != ty; ny += step) {
                if (_mapInfo.isBlocked(fx, fy, tx, ny, _objRadius)) return false;
                fy = ny;
            }
        } else {
            step = dx > 0 ? -1 : 1;
            for (var nx = fx; nx != tx; nx += step) {
                if (_mapInfo.isBlocked(fx, fy, nx, ty, _objRadius)) return false;
                fx = nx;
            }
        }

        return true;
    }

    /**
	 * 修剪探险队
	 * 将失败的探险队，删除出队伍
	 * @flag,本次探险的队伍序号
	 * @return 距离目标最近的探险队序号 -1无探险队
	 */
    private int trimGroup(List<WPoint> group, int flag)
    {
        //删除不存在的队伍
        var i = 0;
        var node = group[flag];
        var cost = System.Int32.MaxValue;
        if (node != null) {
            //更新队伍到目标的距离值
            node.cost = node.getCost(_endPoint);
            //cost = cost;
        } else {
            flag = 0;
        }
        flag = -1;
        var len = group.Count;
        while (i < len) {
            if (group[i] == null) {
                group.RemoveAt(i);
                len--;
                continue;
            }
            node = group[i];
            if (node.cost < cost) {
                cost = node.cost;
                flag = i;
            }
            i++;
        }

        return flag;
    }

    public delegate bool FoundDelegate(int nx, int ny, int ex, int ey);

    private bool defautFound(int nx, int ny, int ex, int ey)
    {
        return nx == ex && ny == ey;
    }

    /**寻找路径，将包含所有节点信息的grid传进来，返回是否找到路径*/
    public List<WPoint> findPath(IWMapInfo mapInfo, int radius, WPoint sp, WPoint ep, FoundDelegate found = null)
    {
        if (_testList != null) _testList.Clear();

        _poolIdx = 0;
        _mapInfo = mapInfo;
        _objRadius = radius;
        _startPoint = sp;
        _endPoint = ep;
        if (_endPoint.isEquals(_startPoint)) {
            //相同点的寻路
            return null;
        }

        //修剪路径
        var nMask = mapInfo.cols() * mapInfo.rows();
        if (_maskList == null || nMask > _maskList.Length) {
            _maskList = new bool[mapInfo.cols() * mapInfo.rows()];
        } else {
            System.Array.Clear(_maskList, 0, _maskList.Length);
        }
                                                               
        return explore(_startPoint, found ?? defautFound);
    }

    /**
	 * 从某个点向目标探索
	 * 
	 * 方向优先 深度优先探索
	 * @return null没有找到
	 */
    private List<WPoint> explore(WPoint node, FoundDelegate found)
    {
        //探索队
        _group.Clear();
        var group = _group;
        group.Add(node);
        WPoint squad;
        var numSquad = 0;
        int dirc, nextDirc, sx, sy;
        var flag = 0;
        var findPath = false;
        bool isMiss;

        //if(_mapInfo.isBlocked(_endPoint.x,_endPoint.y,_objRadius))return null;
        
        //有探索队一直进行探索
        while (group.Count > 0) {
            //每支队伍向目标进发
            flag = trimGroup(group, flag);
            if (flag < 0) {
                //失败的探险
                return null;
            }


            squad = group[flag] as WPoint;
            if (squad == null) continue;

            //获取目标方向
            dirc = squad.getDirection(_endPoint);
            sx = squad.x + DIREC_MOVE[dirc][0];
            sy = squad.y + DIREC_MOVE[dirc][1];
            
            while (!seachBlock(squad.x, squad.y, sx, sy)) {
                if (found(sx, sy, _endPoint.x, _endPoint.y)) {
                    group[flag] = GetPoint(sx, sy, squad);
                    //找到目标
                    findPath = true;
                    break;
                }

                squad = GetPoint(sx, sy, squad);
                //更新队伍
                group[flag] = squad;
                //更新mask
                maskSeach(sx, sy);

                //向前探索
                dirc = squad.getDirection(_endPoint);
                sx = squad.x + DIREC_MOVE[dirc][0];
                sy = squad.y + DIREC_MOVE[dirc][1];
            }

            if (findPath) {
                //找到目标
                break;
            }
            
            //遭遇障碍，根据方向采用不同的策略
            while (isLost(squad)) {
                //迷失的队伍回头
                if (squad.parent == null) {
                    //关闭分支
                    group[flag] = null;
                    squad = null;
                    break;
                }
                squad = squad.parent;
            }
            
            //获取可探险路径再进行探寻
            if (squad != null) {
                if (checkCreateSquad(squad, group, flag, found)) {
                    findPath = true;
                    break;
                }
            }
        }

        if (!findPath) return null;
        
        //归并路径
        node = group[flag];
        var parent = node.parent;
        while (node != null) {
            parent = node.parent;
            while (parent != null) {
                if (parent.parent == null) break;
                if (node.getCost(parent.parent) == 1) {
                    //相邻,归并
                    node.parent = parent.parent;
                } else if (node.x == parent.parent.x || node.y == parent.parent.y) {
                    //检查是否可以直通
                    if (this.isLinePath(node.x, node.y, parent.parent.x, parent.parent.y)) {
                        //改为走直线
                        node.parent = parent.parent;
                    }
                }
                parent = parent.parent;
            }
            node = node.parent;
        }
        //同向点归并
        node = group[flag];
        if (node.parent != null) {
            var direc = node.getDirection(node.parent);
            var newDirec = 0;
            var waitNode = node;
            node = node.parent;
            while (node != null) {
                if (node.parent == null) break;
                newDirec = node.getDirection(node.parent);
                if (newDirec != direc) {
                    //方向改变
                    waitNode.parent = node;
                    direc = newDirec;
                    waitNode = node;
                }
                node = node.parent;
            }
            if (waitNode != node) {
                waitNode.parent = node;
            }
        }

        //回缩路径
        _thePath.Clear();
        node = group[flag];
        while (node.parent != null) {
            _thePath.Add(node);
            node = node.parent;
        }

        return _thePath;
    }



    private List<int> _goDirec = new List<int>();
    /**
	 * 检查并自动创建探险队
	 */
    private bool checkCreateSquad(WPoint node, List<WPoint> group, int flag, FoundDelegate found)
    {
        _goDirec.Clear();
        var goDirec = _goDirec;

        //获取可前进方向
        for (var i = 1; i < 10; i++) {
            if (i == 5) continue;
            var nx = node.x + DIREC_MOVE[i][0];
            var ny = node.y + DIREC_MOVE[i][1];

            if (!seachBlock(node.x, node.y, nx, ny)) {
                if (found(nx, ny, _endPoint.x, _endPoint.y)) {
                    group[flag] = GetPoint(nx, ny, node);
                    return true;
                }
                goDirec.Add(i);
            }
        }
        //根据目标方向进行判断
        if (goDirec.Count < 0) {
            //无方向可以寻找
            throw new System.Exception("checkCreateSquad：错误的寻路调用");
        }

        if (goDirec.Count < 2) {
            //只有一种可能
            toDirec(node, group, flag, goDirec[0]);
            return false;
        }

        //多条探寻可能的时候需要对目标方位进行判断
        var direc = node.getDirection(_endPoint);

        for (var i = 1; i <= 4; i++) {
            if (findDirecGo(i, goDirec, direc, node, group, flag)) {
                break;
            }
        }
        return false;
    }


    /**
	 * 向着目标方向尽量靠近的方向前进
		*/
    private bool findDirecGo(int step, List<int> goDirec, int direc, WPoint node, List<WPoint> group, int flag)
    {
        var inx = DIREC_INX[direc];
        var up = inx + step;
        if (up > 7) up -= 8;
        up = DIREC[up];
        var down = inx - step;
        if (down < 0) down += 8;
        down = DIREC[down];

        var select = down == up ? 1 : selectDirec(up, down, direc);

        var NewSquad = false;
        if (goDirec.Contains(up) && select < 2) {
            toDirec(node, group, flag, up);
            NewSquad = true;
        }
        if (down == up) return NewSquad;

        if (goDirec.Contains(down) && select != 1) {
            toDirec(node, group, NewSquad ? group.Count : flag, down);
            NewSquad = true;
        }

        return NewSquad;
    }



    /**
	 * 方向判断，取最优
	 * @return 0两个都是最优 1最优 22最优
	 */
    private int selectDirec(int select1, int select2, int direc)
    {
        var n1 = DIREC_COST[direc][select1];
        var n2 = DIREC_COST[direc][select2];
        return n1 > n2 ? 1 : (n1 < n2 ? 2 : 0);
    }

    /**
	 *转向
	 */
    private void toDirec(WPoint node, List<WPoint> group, int flag, int direc)
    {
        var point = GetPoint(
            node.x + DIREC_MOVE[direc][0], 
            node.y + DIREC_MOVE[direc][1], node);
        if (group.Count > flag) {
            group[flag] = point;
        } else {
            group.Add(point);
        }
        this.maskSeach(group[flag].x, group[flag].y);
    }

    //检查节点是否迷失
    private bool isLost(WPoint node)
    {
        for (var i = 1; i < 10; i++) {
            if (i == 5) continue;
            if (!seachBlock(node.x, node.y
                           , node.x + DIREC_MOVE[i][0]
                           , node.y + DIREC_MOVE[i][1])
               ) {
                return false;
            }
        }
        return true;
    }
}
