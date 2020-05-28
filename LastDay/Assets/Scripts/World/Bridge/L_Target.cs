using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_Target
    {
        public static CFG_Target CreateFromLua(System.IntPtr lua, int index)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            lua.GetField(index, "Params");
            var Params = lua.ToArrayNumber<int>(-1);
            lua.Pop(1);

            return new CFG_Target(
               (RangeType)lua.GetEnum(index, "rangeType", RangeType.None),
               (int)lua.GetNumber(index, "tarSet"),
               (int)lua.GetNumber(index, "tarLimit"),
               (TARFilter)lua.GetEnum(index, "tarFilter", TARFilter.Nearest),
               Params);
        }
    }
}
