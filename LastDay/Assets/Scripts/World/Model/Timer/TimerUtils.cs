//
//  Utils.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

using System.Collections.Generic;

namespace World
{
    public static class TimerUtils
    {
        public static Timer NewTimer(this IObj self, IObj who, IObj whom, 
            int duration, int interval = 0, int delay = 0)
        {
            return self.L.tmMgr.New(self).Init(who, whom, duration, interval, delay);
        }

        public static Timer ReplaceTimer(this IObj self, string unique, IObj who, IObj whom, 
            int duration, int interval = 0, int delay = 0)
        {
            var tm = self.L.tmMgr.Find(unique) ?? self.L.tmMgr.New(self);            
            return tm.Init(who, whom, duration, interval, delay);
        }

        public static int BreakTimerOf(this IObj self, string tag, string unique)
        {
            return self.L.tmMgr.BreakOf(self, tag, unique);
        }

        public static int BreakTimerOn(this IObj self, string tag, string unique)
        {
            return self.L.tmMgr.BreakOn(self, tag, unique);
        }

        public static List<Timer> GetTimersOf(this IObj self, System.Type paramType)
        {
            var list = TimerManager.GetPool();
            self.L.tmMgr.GetTimersOf(self, paramType, list);
            return list;
        }

        public static List<Timer> GetTimersOn(this IObj self, System.Type paramType)
        {
            var list = TimerManager.GetPool();
            self.L.tmMgr.GetTimersOn(self, paramType, list);
            return list;
        }
    }
}
