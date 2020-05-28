using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_Bullet
    {
        public static CFG_Bullet CreateFromLua(System.IntPtr lua, int index)
        {
            if (!lua.IsTable(index)) return null;

            if (index < 0) index = lua.GetTop() + 1 + index;

            lua.GetField(index, "Params");
            var Params = lua.ToArrayNumber<int>(-1);
            lua.Pop(1);

            return new CFG_Bullet(new CFG_Bullet.Form() {
                mode = (BulletMode)lua.GetEnum(index, "mode", BulletMode.Normal),
                sizeA = lua.GetNumber(index, "sizeA"),
                sizeB = lua.GetNumber(index, "sizeB"),
                speed = (int)lua.GetNumber(index, "speed"),
                tarLimit = (int)lua.GetNumber(index, "tarLimit"),
                fx = lua.GetString(index, "fx"), sfx = lua.GetString(index, "sfx"),
                Params = Params,
            });
        }
    }
}
