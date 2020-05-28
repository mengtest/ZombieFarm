using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_SubSk
    {
        public static CFG_SubSk Creator(int id, CFG_Skill Skill)
        {
            var lua = DataUtil.LuaLoadConfig("load_subsk", id);
            var Sub = CreateFromLua(Skill, lua, -1);
            lua.Pop(1);

            return Sub;
        }

        private static CFG_SubSk CreateFromLua(CFG_Skill Skill, System.IntPtr lua, int index)
        {
            if (!lua.IsTable(index)) return null;

            if (index < 0) index = lua.GetTop() + 1 + index;

            var form = new CFG_SubSk.Form() {
                tarType = (TARType)lua.GetEnum(index, "tarType", TARType.None),
                delay = (int)lua.GetNumber(index, "delay"),
                cost = (int)lua.GetNumber(index, "cost"),
                live = lua.GetBoolean(index, "live"),
                fxH = lua.GetString(index, "fxH"), sfxH = lua.GetString(index, "sfxH"),

                freq = (int)lua.GetNumber(index, "freq"),
                interval = (int)lua.GetNumber(index, "interval"),
                holdFx = new FxView(
                    lua.GetString(index, "fxG"),
                    lua.GetString(index, "fxGT"),
                    lua.GetString(index, "sfxG")),
            };

            lua.GetField(index, "Target");
            var Target = L_Target.CreateFromLua(lua, -1);
            lua.Pop(1);

            lua.GetField(index, "Missile");
            var Bullet = L_Bullet.CreateFromLua(lua, -1);
            lua.Pop(1);

            var Sub = new CFG_SubSk(Skill,
                (int)lua.GetNumber(index, "id"), form, Target, Bullet);

            lua.GetField(index, "Effs");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var Eff = L_Effect.CreateFromLua(Sub, lua, -1);
                    lua.Pop(1);

                    if (Eff != null) Sub.AddEffect(Eff);
                }
            }
            lua.Pop(1);

            return Sub;
        }
    }
}
