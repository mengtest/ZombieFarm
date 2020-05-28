//
//  CVar.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

namespace World
{
    public static class CVar
    {
        /// <summary>
        /// 每秒帧数
        /// </summary>
        public const int FRAME_RATE = 30;
        /// <summary>
        /// 每帧的时间（秒）
        /// </summary>
        public const float FRAME_TIME = 1f / FRAME_RATE;
        /// <summary>
        /// 长度换算系数
        /// </summary>
        public const float LENGTH_MUL = 1000f;
        /// <summary>
        /// 长度换算系数
        /// </summary>
        public const float LENGTH_RATE = 1 / LENGTH_MUL;

        /// <summary>
        /// 移动速率最小变化值
        /// </summary>
        public const float MOVE_SPEED_DIFF = 0.1f;
        
        /// <summary>
        /// 几乎完全朝向
        /// </summary>
        public const float DOT_FORWARD_COMPLETELY = 0.99f;

        /// <summary>
        /// 正面朝向
        /// </summary>
        public const float DOT_FORWARD = 0.9f;

        public const float MIN_RNG = 1f;
        public const float MELEE_RNG = 1.5f;

        /// <summary>
        /// 完全遮挡值
        /// </summary>
        public const int FULL_BLOCK = 99;

        /// <summary>
        /// 一个单位的技能数量上限
        /// </summary>
        public const int SKILL_CAP = 10;

        /// <summary>
        /// 交互动作ID最小值
        /// </summary>
        public const int INTERACT_ID = 100;

        /// <summary>
        /// 拾取的动作编号
        /// </summary>
        public const int PICK_ID = 1;
        
        /// <summary>
        /// 打开箱子的动作编号
        /// </summary>
        public const int OPEN_ID = 2;

        /// <summary>
        /// 背包容量上限
        /// </summary>
        public const int BAG_CAP = 100;
        /// <summary>
        /// 主武器槽位编号
        /// </summary>
        public readonly static int MAJOR_POS = Pos2Id(1, 1);
        /// <summary>
        /// 副武器槽位编号
        /// </summary>
        public readonly static int MINOR_POS = Pos2Id(1, 0);

        /// <summary>
        /// 通用NPC阵营
        /// </summary>
        public const int NPC_CAMP = 1;

        /// <summary>
        /// 自己家的阵营
        /// </summary>
        public const int HOME_CAMP = 3;

        /// <summary>
        /// 移动同步的最大误差时间
        /// </summary>
        public const float SYNC_DIST = 5f;

        /// <summary>
        /// 方向移动的最大距离
        /// </summary>
        public const float FWD_DIST = 3f;

        public static int Pos2Id(int bag, int pos)
        {
            return bag * BAG_CAP + pos + 1;
        }

        /// <summary>
        /// 帧数转为秒
        /// </summary>
        public static float F2S(int frame)
        {
            return frame * FRAME_TIME;
        }

        /// <summary>
        /// 秒转为帧数
        /// </summary>
        public static int S2F(float seconds)
        {
            return (int)(seconds * FRAME_RATE + 0.5f);
        }
    }
}
