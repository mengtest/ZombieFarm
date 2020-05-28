using UnityEngine;
using System.Collections;
using Math = System.Math;

/**
	 * 地图点信息
	 */
public class WPoint
{
	public int x { get; private set; }
    public int y { get; private set; }
    public int cost;
    public WPoint parent;
	public WPoint(int x = 0, int y = 0, WPoint p = null)
	{
        Update(x, y, p);
	}
    public void Update(int x, int y, WPoint p)
    {
        this.x = x;
        this.y = y;
        parent = p;
        cost = 0;
    }
	
	/**
	 * 比较两个点是否相同
	 */
	public bool isEquals(int tx, int ty)
	{
		return x==tx && y==ty;
	}

	public bool isEquals(WPoint wp)
	{
		return isEquals(wp.x, wp.y);
	}
	
	/**
	 * 转换坐标为点阵
	 */
	public void realToCell()
	{
		x = WPoint.realToCell(x);
		y = WPoint.realToCell(y);
	}
	
	/**
	 * 点阵转换为实际坐标
	 */
	public void cellToReal()
	{
		x = WPoint.cellToReal(x);
		y = WPoint.cellToReal(y);
	}
	
	/**
	 * 获取距离代价
	 */
	public int getCost(WPoint other)
	{
		var dx = x - other.x;
		var dy = y - other.y;
		return dx*dx+dy*dy;
	}
	
	/**
	 * 获取距离
	 */
	public int getDistance(WPoint other)
	{
		return 0;//    Vector2.Distance(new Vector2(this.x, this.y), new Vector2(other.x, other.y));
	}
	
	/**
	 * 获得该点到别的点的方向
	 * 8方向表示
	 * @return 1-9表示8个方向 5表示相同点
	 */
	public int getDirection(WPoint other)
	{
		return WPoint.getDirection(x,y,other.x,other.y);
	}

	public override string ToString()
	{
		return "["+x+","+y+"]";
	}
	
	
	/**
	 * 获得两个点之间的方向
	 * 8方向表示
	 * @return 1-9表示8个方向 5表示相同点
	 */
	public static int getDirection(int fx, int fy, int tx, int ty)
	{
        var yOff = Math.Abs(fy - ty);
        var xOff = Math.Abs(fx - tx);
        //if (yOff > xOff) {
        //    return fy > ty ? 8 : 2;
        //} else if (yOff < xOff) {
        //    return fx > tx ? 4 : 6;
        //}
        // 优先横向方向
        if (yOff < xOff) {
            return fx > tx ? 4 : 6;
        }

        if (fx > tx) {
            //左方向
            return fy > ty ? 7 : (fy < ty ? 1 : 4);
        } else if (fx < tx) {
            //右方向
            return fy > ty ? 9 : (fy < ty ? 3 : 6);
        } else {
            return fy > ty ? 8 : (fy < ty ? 2 : 5);
        }
    }
	/**
	 * 获得两个点之间的左右方向
	 * @return 4左 6右 0表示一个x轴上
	 */
	public static int get2Direction(int fx, int fy, int tx, int ty)
	{
		return fx>tx?4:(fx<tx?6:0);
	}
	
	/**
	 * 转换坐标为点阵
	 */
	static public int realToCell(int value)
	{
		return 0;//value/WMapConfig.CELL_SIZE;
	}
	
	/**
	 * 点阵转换为实际坐标
	 */
	static public int cellToReal(int value)
	{
		return 0;
		/*
		if(WMapConfig.ENABLE_CELL_CENTER){
			return value*WMapConfig.CELL_SIZE + WMapConfig.HELF_CELL_SIZE;
		}
		else{
			return value*WMapConfig.CELL_SIZE;
		}
		*/
	}
	
	/**
	 * 两点间距离
	 */
	static public float getDistance(int fx, int fy, int tx, int ty)
	{
		return 0;//Vector2.Distance(new Vector2(fx,fy),new Vector2(tx,ty));
	}
}
