using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_Effect
    {
        public static CFG_Effect CreateFromLua(CFG_SubSk Sub, System.IntPtr lua, int index)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            int id = (int)lua.GetNumber(index, "id");
            var func = lua.GetString(index, "func");

            CFG_Effect Eff = null;

            lua.GetField(index, "Params");
            if (lua.IsTable(-1)) {
                switch (func) {
                    case "damage": {
                            var unitMask = (int)lua.GetNumber(-1, 1);
                            var dmgType = (int)lua.GetNumber(-1, 2);
                            Eff = new DamageEffect(Sub, id, func, unitMask, dmgType);

                            break;
                        }
                    case "directDamage":
                        Eff = new DirectDamage(Sub, id, func);
                        break;
                    case "reload": {
                            var mode = (int)lua.GetNumber(-1, 1);
                            var value = (int)lua.GetNumber(-1, 2);
                            Eff = new ReloadEffect(Sub, id, func, mode, value);
                            break;
                        }
                    default: break;
                }
            }
            lua.Pop(1);

            return Eff;
        }
    }
}
