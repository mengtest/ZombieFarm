using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_Buff
    {
        public static SimpleBuff Creator(int id)
        {
            var lua = DataUtil.LuaLoadConfig("load_buff", id);
            var Buff = CreateFromLua(lua, -1);
            lua.Pop(1);

            return Buff;
        }

        private static SimpleBuff CreateFromLua(System.IntPtr lua, int index)
        {
            if (!lua.IsTable(index)) return null;
            if (index < 0) index = lua.GetTop() + 1 + index;

            var id = (int)lua.GetNumber(index, "id");
            var fxName = lua.GetString(index, "fx");
            var Buff = new SimpleBuff(id, fxName);

            lua.GetField(index, "Funcs");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var func = lua.ToString(-1);
                    lua.Pop(1);
                    Buff.Funcs.Add(func);
                }
                lua.Pop(1);
            }

            return Buff;
        }
    }
}
